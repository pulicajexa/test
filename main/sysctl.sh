#!/usr/bin/env bash
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
cat << 'EOT' > /etc/sysctl.conf

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

echo -n "" > /etc/resolv.conf
cat >/etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
