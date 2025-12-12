#!/bin/bash

# ========================== #
#   SSH PORT CHANGER – UI    #
#        DEFAULT 1632        #
# ========================== #

NEW_PORT=1632

GREEN="\e[92m"
RED="\e[91m"
YELLOW="\e[93m"
BLUE="\e[94m"
RESET="\e[0m"

clear
echo -e "${BLUE}"
echo -e "─────────────────────────────────────────────"
echo -e "       🚀 SSH PORT CHANGER                  "
echo -e "─────────────────────────────────────────────"
echo -e "${RESET}"

echo -e "${YELLOW}⚙ Đổi port SSH sang ${GREEN}$NEW_PORT${YELLOW}...${RESET}"
sleep 0.6

# 1. Stop socket activation
echo -e "${YELLOW}🔍 Kiểm tra ssh.socket...${RESET}"
if systemctl is-active --quiet ssh.socket; then
    echo -e "${YELLOW}⚠️ Đang tắt ssh.socket...${RESET}"
    systemctl stop ssh.socket
    systemctl disable ssh.socket
    sleep 0.3
    echo -e "${GREEN}✔ ssh.socket đã bị vô hiệu hoá${RESET}"
else
    echo -e "${GREEN}✔ ssh.socket không hoạt động${RESET}"
fi

# 2. Remove previous Ports
echo -e "${YELLOW}🧹 Xóa cấu hình port cũ...${RESET}"
sed -i '/^Port /d' /etc/ssh/sshd_config 2>/dev/null
for f in /etc/ssh/sshd_config.d/*.conf; do
    sed -i '/^Port /d' "$f" 2>/dev/null
done
sleep 0.3
echo -e "${GREEN}✔ Đã xoá tất cả port cũ${RESET}"

# 3. Write new port
echo -e "${YELLOW}📝 Tạo file port mới...${RESET}"
cat <<EOF >/etc/ssh/sshd_config.d/99-port.conf
Port $NEW_PORT
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
EOF
sleep 0.3
echo -e "${GREEN}✔ Port mới được đặt thành: $NEW_PORT${RESET}"

# 4. Firewall
echo -e "${YELLOW}🛡 Cập nhật firewall...${RESET}"
if command -v ufw >/dev/null 2>&1; then
    ufw allow $NEW_PORT/tcp >/dev/null 2>&1
    ufw delete allow 22/tcp >/dev/null 2>&1
fi

iptables -A INPUT -p tcp --dport $NEW_PORT -j ACCEPT
iptables -D INPUT -p tcp --dport 22 -j ACCEPT >/dev/null 2>&1

echo -e "${GREEN}✔ Firewall đã mở port $NEW_PORT & tắt port 22${RESET}"

# 5. Check config
echo -e "${YELLOW}🔧 Kiểm tra cấu hình SSH...${RESET}"
if ! sshd -t; then
    echo -e "${RED}❌ Lỗi cấu hình SSH!${RESET}"
    exit 1
fi
echo -e "${GREEN}✔ Cấu hình SSH hợp lệ${RESET}"

# 6. Restart
echo -e "${YELLOW}🔄 Restart SSH...${RESET}"
systemctl restart ssh || systemctl restart sshd
sleep 0.4

# 7. Verify
echo -e "${YELLOW}🔎 Kiểm tra port mới...${RESET}"
sleep 0.4

if ss -lntp | grep -q ":$NEW_PORT"; then
    echo -e "${GREEN}"
    echo -e "🎉 HOÀN TẤT!"
    echo -e "SSH hiện đang chạy trên port: $NEW_PORT"
    echo -e "─────────────────────────────────────────────${RESET}"
else
    echo -e "${RED}❌ SSH KHÔNG chạy trên port mới!${RESET}"
fi
