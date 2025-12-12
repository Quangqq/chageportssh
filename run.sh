#!/bin/bash

# Port mới muốn đổi
PORT=1632

# Lấy IP public tự động
IP=$(curl -s ipv4.icanhazip.com)

echo "[+] Địa chỉ IP phát hiện: $IP"
echo "[+] Chuẩn bị đổi port SSH sang $PORT..."

SSHD_CONFIG="/etc/ssh/sshd_config"

# Gỡ immutable nếu cần
if lsattr $SSHD_CONFIG | grep -q "i"; then
    echo "[+] File bị khóa immutable. Đang mở khóa..."
    sudo chattr -i $SSHD_CONFIG
fi

# Backup
echo "[+] Tạo bản sao dự phòng..."
sudo cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

# Sửa port SSH
echo "[+] Thay đổi port trong sshd_config..."
sudo sed -i "s/^#Port .*/Port $PORT/" $SSHD_CONFIG
sudo sed -i "s/^Port .*/Port $PORT/" $SSHD_CONFIG

# Nếu chưa có thì thêm dòng Port
grep -q "^Port" $SSHD_CONFIG || echo "Port $PORT" | sudo tee -a $SSHD_CONFIG

echo "[+] Mở firewall..."

# UFW
if command -v ufw >/dev/null 2>&1 ; then
    sudo ufw allow $PORT/tcp
fi

# FirewallD
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --permanent --add-port=$PORT/tcp
    sudo firewall-cmd --reload
fi

# iptables
if command -v iptables >/dev/null 2>&1 ; then
    sudo iptables -A INPUT -p tcp --dport $PORT -j ACCEPT
fi

echo "[+] Restart SSH..."
sudo systemctl restart ssh || sudo service ssh restart

echo ""
echo "=============================="
echo "     SSH PORT ĐÃ ĐƯỢC ĐỔI"
echo "=============================="
echo "IP VPS:        $IP"
echo "Port mới:      $PORT"
echo "Đăng nhập bằng:"
echo ""
echo "ssh -p $PORT root@$IP"
echo ""
echo "Backup config: ${SSHD_CONFIG}.bak"
echo "=============================="
