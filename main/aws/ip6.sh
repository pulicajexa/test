#!/bin/bash

# 本地脚本
apt install net-tools -y
apt install sipcalc -y
sleep 2
a=$(ip -6 addr show | grep -v "lo:" | grep -oP '^\d+: \K[^:]+')
SUBNET_MASK=$(ip -6 addr show $a | grep "global" | awk '{print $2}' | cut -d/ -f2 | head -n1)
echo "网卡名称：$a"
echo "子网位数：128"
read -p "请输入私有ip: " enterip1
enterip="$enterip1"
echo "ip -6 addr add $enterip/128 dev $a"
echo "创建启动脚本文件"
cat >/etc/privateIP.sh <<EOF
#! /bin/bash

ip -6 addr add $enterip/128 dev $a
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
ipAddr=$(ip -6 addr show dev $a | grep global | awk '{print $2}')
echo -e "\e[1;32m 当前IPv6地址: $ipAddr \e[0m"
sleep 1
echo "部署好副ip绑定进程"
