#!/bin/bash

# Port mới muốn đổi
PORT=1632

echo "[+] Kiểm tra file sshd_config..."
SSHD_CONFIG="/etc/ssh/sshd_config"

# Gỡ immutable nếu có
if lsattr $SSHD_CONFIG | grep -q "i"; then
    echo "[+] Gỡ immutable..."
    chattr -i $SSHD_CONFIG
fi

# Backup trước khi sửa
cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

echo "[+] Thay đổi port SSH thành $PORT..."

# Xóa port cũ và thêm port mới
sed -i "s/^#Port .*/Port $PORT/" $SSHD_CONFIG
sed -i "s/^Port .*/Port $PORT/" $SSHD_CONFIG

# Nếu file chưa có dòng Port, thêm vào đầu
grep -q "^Port" $SSHD_CONFIG || echo "Port $PORT" >> $SSHD_CONFIG

echo "[+] Mở firewall cho port mới..."

# UFW
if command -v ufw >/dev/null 2>&1 ; then
    ufw allow $PORT/tcp
fi

# FirewallD
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-port=$PORT/tcp
    firewall-cmd --reload
fi

# iptables
if command -v iptables >/dev/null 2>&1 ; then
    iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
fi

echo "[+] Restart SSH..."
systemctl restart sshd || service ssh restart

echo ""
echo "============================"
echo "   SSH PORT ĐÃ ĐỔI → $PORT"
echo "============================"
echo "Hãy đăng nhập bằng:"
echo "ssh -p $PORT root@IP_VPS"
echo ""
