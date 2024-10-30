#!/bin/bash
# By Alva

# 颜色输出函数
red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}

check_system() {
    lsb_release -a
}
#debian11步骤
debian11() {
export DEBIAN_FRONTEND=noninteractive
##
mkfs.ext4 /dev/xvdb -N 5359296

# set timezone to Asia/Hong_Kong
sudo timedatectl set-timezone Asia/Hong_Kong

# Increase file handle limit
cat << 'EOT' >> /etc/security/limits.conf
# Increase file handle limit
* soft     nproc          1024000
* hard     nproc          1024000
* soft    nofile           1024000
* hard    nofile          1024000
root soft     nproc          1024000
root hard     nproc          1024000
root soft     nofile         1024000
root hard     nofile         1024000
EOT

echo "ulimit -SHn 1024000" >> /etc/profile

# Optimize TCP performance with sysctl.conf
cat << 'EOT' >> /etc/sysctl.conf

net.core.default_qdisc = fq_pie
net.ipv4.tcp_congestion_control = bbr
net.core.somaxconn = 40960
net.ipv4.tcp_abort_on_overflow = 1
# max open files
fs.file-max = 1024000
# Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.udp_mem = 65536 131072 262144
# Maximum Socket Send Buffer up to 128MB
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
# Increase the read-buffer space allocatable (minimum size,
# initial size, and maximum size in bytes)
net.ipv4.tcp_rmem = 10240 87380 67108864
net.ipv4.tcp_wmem = 10240 87380 67108864
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
# change TLS in TLS packet size exposure
# default receive and send buffer size
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
# Increase number of incoming connections backlog queue
# Sets the maximum number of packets, queued on the INPUT
# side, when the interface receives packets faster than
# kernel can process them.
net.core.netdev_max_backlog = 262144
# Increase the maximum amount of option memory buffers
net.core.optmem_max = 25165824
# Disable TCP SACK (TCP Selective Acknowledgement),
# DSACK (duplicate TCP SACK), and FACK (Forward Acknowledgement)
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fack = 1
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 655360
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 500
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
# Number of times SYNACKs for passive TCP connection.
net.ipv4.tcp_synack_retries = 2
# outbound port range
net.ipv4.ip_local_port_range = 1024 65535
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 262144
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# enable ip forwarding
net.ipv4.ip_forward = 1
# This allows fast cycling of sockets in time_wait state and re-using them.
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse=1

EOT

sysctl -p

green "系统参数配置完成"

echo -n "" > /etc/resolv.conf
cat >/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

green "DNS配置为googleDNS,完成！"

green "修改为debian11官方源"
cat > /etc/apt/sources.list << EOF
deb https://deb.debian.org/debian/ bullseye main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye main contrib non-free

deb https://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye-updates main contrib non-free

deb https://deb.debian.org/debian/ bullseye-backports main contrib non-free
deb-src https://deb.debian.org/debian/ bullseye-backports main contrib non-free

deb https://deb.debian.org/debian-security/ bullseye-security main contrib non-free
deb-src https://deb.debian.org/debian-security/ bullseye-security main contrib non-free
EOF

apt update -y
apt upgrade -y
green "安装时间同步程序"
sudo apt install -y systemd-timesyncd
sleep 5
echo -n "" > /etc/systemd/timesyncd.conf
cat >/etc/systemd/timesyncd.conf <<EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See timesyncd.conf(5) for details.

[Time]
NTP=time1.google.com time.apple.com time.cloudflare.com time.windows.com
#FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048

EOF

green "时间服务器配置完毕"
systemctl restart systemd-timesyncd
green "重启时间同步服务器"
systemctl restart systemd-timesyncd
green "开启服务器的 NTP 同步功能"
timedatectl set-ntp true
green "修改主板时间"
hwclock -w
}

#debian12步骤
debian12() {
export DEBIAN_FRONTEND=noninteractive
##
mkfs.ext4 /dev/xvdb -N 5359296

# set timezone to Asia/Hong_Kong
sudo timedatectl set-timezone Asia/Hong_Kong

# Increase file handle limit
cat << 'EOT' >> /etc/security/limits.conf
# Increase file handle limit
* soft     nproc          1024000
* hard     nproc          1024000
* soft    nofile           1024000
* hard    nofile          1024000
root soft     nproc          1024000
root hard     nproc          1024000
root soft     nofile         1024000
root hard     nofile         1024000
EOT

echo "ulimit -SHn 1024000" >> /etc/profile

# Optimize TCP performance with sysctl.conf
cat << 'EOT' >> /etc/sysctl.conf

net.core.default_qdisc = fq_pie
net.ipv4.tcp_congestion_control = bbr
net.core.somaxconn = 40960
net.ipv4.tcp_abort_on_overflow = 1
# max open files
fs.file-max = 1024000
# Do less swapping
vm.swappiness = 10
vm.dirty_ratio = 60
vm.dirty_background_ratio = 2
# Increase the maximum total buffer-space allocatable
# This is measured in units of pages (4096 bytes)
net.ipv4.tcp_mem = 65536 131072 262144
net.ipv4.udp_mem = 65536 131072 262144
# Maximum Socket Send Buffer up to 128MB
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
# Increase the read-buffer space allocatable (minimum size,
# initial size, and maximum size in bytes)
net.ipv4.tcp_rmem = 10240 87380 67108864
net.ipv4.tcp_wmem = 10240 87380 67108864
net.ipv4.udp_rmem_min = 16384
net.ipv4.udp_wmem_min = 16384
# recommended for hosts with jumbo frames enabled
net.ipv4.tcp_mtu_probing=1
# change TLS in TLS packet size exposure
# default receive and send buffer size
net.core.rmem_default = 16777216
net.core.wmem_default = 16777216
# Increase number of incoming connections backlog queue
# Sets the maximum number of packets, queued on the INPUT
# side, when the interface receives packets faster than
# kernel can process them.
net.core.netdev_max_backlog = 262144
# Increase the maximum amount of option memory buffers
net.core.optmem_max = 25165824
# Disable TCP SACK (TCP Selective Acknowledgement),
# DSACK (duplicate TCP SACK), and FACK (Forward Acknowledgement)
net.ipv4.tcp_sack = 1
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_fack = 1
# resist SYN flood attacks
net.ipv4.tcp_syncookies = 1
# reuse timewait sockets when safe
net.ipv4.tcp_tw_reuse = 1
# max timewait sockets held by system simultaneously
net.ipv4.tcp_max_tw_buckets = 655360
# short FIN timeout
net.ipv4.tcp_fin_timeout = 30
# Decrease the time default value for connections to keep alive
net.ipv4.tcp_keepalive_time = 500
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.tcp_keepalive_intvl = 15
# Number of times SYNACKs for passive TCP connection.
net.ipv4.tcp_synack_retries = 2
# outbound port range
net.ipv4.ip_local_port_range = 1024 65535
# max SYN backlog
net.ipv4.tcp_max_syn_backlog = 262144
# turn on TCP Fast Open on both client and server side
net.ipv4.tcp_fastopen = 3
# enable ip forwarding
net.ipv4.ip_forward = 1
# This allows fast cycling of sockets in time_wait state and re-using them.
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_tw_reuse=1

EOT

sysctl -p

green "系统参数配置完成"

echo -n "" > /etc/resolv.conf
cat >/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

green "DNS配置为googleDNS,完成！"

green "修改为debian12官方源"
cat > /etc/apt/sources.list << EOF
deb http://deb.debian.org/debian/ bookworm main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free-firmware
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free-firmware
deb http://deb.debian.org/debian/ bookworm-backports main contrib non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-backports main contrib non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free-firmware
deb-src http://deb.debian.org/debian-security/ bookworm-security main contrib non-free-firmware
EOF


apt update -y
apt upgrade -y
green "安装时间同步程序"
sudo apt install -y systemd-timesyncd
sleep 5
echo -n "" > /etc/systemd/timesyncd.conf
cat >/etc/systemd/timesyncd.conf <<EOF
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU Lesser General Public License as published by
#  the Free Software Foundation; either version 2.1 of the License, or
#  (at your option) any later version.
#
# Entries in this file show the compile time defaults.
# You can change settings by editing this file.
# Defaults can be restored by simply deleting this file.
#
# See timesyncd.conf(5) for details.

[Time]
NTP=time1.google.com time.apple.com time.cloudflare.com time.windows.com
#FallbackNTP=0.debian.pool.ntp.org 1.debian.pool.ntp.org 2.debian.pool.ntp.org 3.debian.pool.ntp.org
#RootDistanceMaxSec=5
#PollIntervalMinSec=32
#PollIntervalMaxSec=2048

EOF

green "时间服务器配置完毕"
systemctl restart systemd-timesyncd
green "重启时间同步服务器"
systemctl restart systemd-timesyncd
green "开启服务器的 NTP 同步功能"
timedatectl set-ntp true
green "修改主板时间"
hwclock -w
}

#谷歌学术ipv6地址
googlev6(){
    green "已设置IPV6对谷歌学术的解析"
echo "2404:6800:4008:c06::be scholar.google.com
2404:6800:4008:c06::be scholar.google.com.hk
2404:6800:4008:c06::be scholar.google.com.tw
2401:3800:4001:10::101f scholar.google.cn #www.google.cn
2404:6800:4008:c06::be scholar.google.com.sg
2404:6800:4008:c06::be scholar.l.google.com
2404:6800:4008:803::2001 scholar.googleusercontent.com" >> /etc/hosts
}

host_nameset(){
    read -p "请输入要设置的主机名：" name_host
    hostnamectl set-hostname $name_host
    reboot
}


# 主菜单
main_menu() {
    green "====================================="
    green " 欢迎使用Alva的一键脚本"
    green " 介绍：基础配置"
    green " 系统：Debian"
    green " 作者：Alva"
    green "====================================="
    green " 1.debian11"
    green " 2.debian12"
    green " 3.谷歌学术ipv6地址"
    green " 4.修改主机名"
    green " 0.退出脚本"
    read -r -p "请输入数字:" num
    case "$num" in
    1)
        debian11
        ;;
    2)
        debian12
        ;;
    3)
        googlev6
        ;;
    4)
        host_nameset
        ;;
    0)
        exit 1
        ;;
    *)
        clear
        red "请输入正确数字"
        sleep 1s
        main_menu
        ;;
    esac
}

# 脚本开始
check_system
main_menu
