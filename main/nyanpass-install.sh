#!/bin/bash
set -e
if [ -n "$DEBUG_INSTALL" ]; then
    set -x
fi

warning() { echo -e "\033[31m\033[01m$*\033[0m"; }         # 红色
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; } # 红色
info() { echo -e "\033[32m\033[01m$*\033[0m"; }            # 绿色
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }            # 黄色

if [ -z "$DOWNLOAD_HOST" ]; then
    DOWNLOAD_HOST="https://dl.nyafw.com"
fi

PRODUCT_EXE="$1"
PRODUCT_ARGUMENTS="$2"
service_name="aws"

case $PRODUCT_EXE in
rel_nodeclient) true ;;
*) error "输入有误" ;;
esac

if [ -z "$PRODUCT_ARGUMENTS" ]; then
    error "输入有误"
fi

if [ "$PRODUCT_ARGUMENTS" == "update" ]; then
    if [ -z "$BG_UPDATE" ]; then
        BG_UPDATE=1 bash "update.sh" "$1" "$2" >/dev/null 2>&1 &
        exit
    fi
fi

#### 判断处理器架构

case $(uname -m) in
aarch64 | arm64) ARCH=arm64 ;;
x86_64 | amd64) [[ "$(awk -F ':' '/flags/{print $2; exit}' /proc/cpuinfo)" =~ avx2 ]] && ARCH=amd64v3 || ARCH=amd64 ;;
*) error "cpu not supported" ;;
esac

if grep "Intel Core Processor (Broadwell)" /proc/cpuinfo >/dev/null 2>&1; then
    ARCH=amd64
fi

PRODUCT="$PRODUCT_EXE"_linux_"$ARCH"

#### 检查重复服务名

if [ -f "/etc/systemd/system/${service_name}.service" ]; then
    warning "该服务已经存在，请先卸载："
    echo "systemctl disable --now $service_name ; rm -rf /opt/$service_name ; rm -f /etc/systemd/system/$service_name.service"
    exit
fi

mkdir -p /etc/systemd/system
mkdir -p ~/.config
mkdir -p /opt/"${service_name}"
cd /opt/"${service_name}"

#### Download & unzip

rm -rf temp_backup
mkdir -p temp_backup

if [ -z "$NO_DOWNLOAD" ]; then
    mv "$PRODUCT_EXE" temp_backup/ || true
    curl ${CURL_FLAGS:+$CURL_FLAGS} -fLSsO "$DOWNLOAD_HOST"/download/download.sh || true
    bash download.sh "$DOWNLOAD_HOST" "$PRODUCT" || true
fi

if [ -f "$PRODUCT_EXE" ]; then
    rm -rf temp_backup
else
    mv temp_backup/* . || true
    error "下载失败！"
fi

#### Install

rm -f download.sh update.sh nyanpass-install.sh temp_backup temp_download

rm -f start.sh
echo 'source ./env.sh || true' >>start.sh
echo './'"$PRODUCT_EXE" "$PRODUCT_ARGUMENTS" >>start.sh
chmod +x start.sh


echo "[Unit]
Description=nyanpass
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service
[Service]
Type=simple
LimitAS=infinity
LimitRSS=infinity
LimitCORE=infinity
LimitNOFILE=999999
User=root
Restart=always
RestartSec=3
WorkingDirectory=/opt/${service_name}
ExecStart=/bin/bash /opt/${service_name}/start.sh
[Install]
WantedBy=multi-user.target
" >/etc/systemd/system/"${service_name}".service

systemctl daemon-reload
systemctl enable --now "${service_name}"
systemctl restart "${service_name}"

info "安装成功"
info "如需卸载，请运行以下命令："
echo "systemctl disable --now ${service_name} ; rm -rf /opt/${service_name} ; rm -f /etc/systemd/system/${service_name}.service"

UNINSTALL_FILE="/opt/${service_name}.uninstall.sh"
echo_uninstall_to_file "$service_name" "$UNINSTALL_FILE"
info "或者："
echo "bash $UNINSTALL_FILE"

#### 检查 bbr

info "当前 TCP 阻控算法: " "$(cat /proc/sys/net/ipv4/tcp_congestion_control)"
