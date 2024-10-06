#!/bin/bash

# 本地脚本
apt install net-tools -y
apt install sipcalc -y
sleep 2
a=$(ip link show | grep -v "lo:" | grep -oP '^\d+: \K[^:]+')
SUBNET_MASK=$(ip addr show $a | grep "inet\b" | awk '{print $2}' | cut -d/ -f2 | head -n1)
echo "网卡名称：$a"
echo "子网位数：$SUBNET_MASK"
read -p "请输入私有ip: " enterip1
enterip="$enterip1"
echo "ip addr add $enterip/$SUBNET_MASK dev $a"
echo "创建启动脚本文件"
cat >/etc/privateIP.sh <<EOF
#! /bin/bash

ip addr add $enterip/$SUBNET_MASK dev $a
EOF

# 提升文件权限
echo "赋予privateIP权限"
chmod +x /etc/privateIP.sh

# 运行添加ip联网
echo "privateIP添加成功"
bash /etc/privateIP.sh  # 使用完整路径执行
# 添加服务
echo "创建进程守护文件"
cat >/etc/systemd/system/privateIP.service <<EOF
[Unit]
Description=privateIP server
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
WorkingDirectory=/etc/
ExecStart=/etc/privateIP.sh

[Install]
WantedBy=multi-user.target
EOF

echo "赋予privateIP服务权限"
chmod 755 /etc/systemd/system/privateIP.service
echo "系统服务重载"
systemctl daemon-reload
echo "启动privateIP服务"
systemctl start privateIP.service
echo "privateIP服务开机自启"
systemctl enable privateIP.service
echo "privateIP状态"
echo -e "\e[1;32m $a \e[0m"
ipAddr=$(ip addr show | grep inet | grep -v inet6 | grep '/20' | awk '{print $2}' | awk -F '/' '{print $1}')
echo -e "\e[1;32m $ipAddr \e[0m"
sleep 1
echo "部署好副ip绑定进程"
