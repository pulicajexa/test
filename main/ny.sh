#!/bin/bash
# By one

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

# 检查系统是否为Debian/CentOS，并安装wget
check_system() {
    green "开始检查系统"
    if [[ -f /etc/redhat-release ]]; then
        release="centos"
    elif cat /etc/issue | grep -q -E -i "debian|ubuntu"; then
        release="debian"
    elif cat /proc/version | grep -q -E -i "debian|ubuntu"; then
        release="debian"
    fi
    green "系统检查完成"

    if [ ! -f "/usr/bin/wget" ]; then
        yellow "检查到系统没有安装wget，开始安装wget"
        if [ "$release" == "centos" ]; then
            yum install wget -y
        elif [ "$release" == "debian" ]; then
            apt-get install wget -y
        fi
    fi
}

#NY-SG
ny_SG(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t 26f7e5b2-48dc-41aa-988d-29aa12017d18 -u https://ny.plu.lol"
}

#NY-JP
NY_JP(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t 0143f3c2-6976-4bcd-97a1-7ce161a63d1c -u https://ny.plu.lol"
}

#NY-HK-2C
NY_HK2C(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t ce683d7b-c764-4904-b7f4-d24364f20b11 -u https://ny.plu.lol"
}
#NY-HK-4C
NY_HK4C(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t 97025562-d197-4a07-b669-28224aa39b25 -u https://ny.plu.lol"
}
#NY-C5n.xlarge
NY_C5n(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t 734909b2-7dfe-4765-8b9e-07bf054d068a -u https://ny.plu.lol"
}

#NY-USA
NY_USA(){
  bash <(curl -fLSs https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/nyanpass-install.sh) rel_nodeclient "-o -t 12dd0dd5-8ced-4de5-9db8-1f88e595b796 -u https://ny.plu.lol"
}
#检查docker是否安装
check_docker(){
    if ! command -v docker &> /dev/null; then
        echo "docker未安装，正在执行安装......"
        apt-get update
        curl -sSL https://get.docker.com/ | sh
        service docker restart
        systemctl enable docker
        echo "Docker 安装完成！执行安装new-api...."
        if sudo systemctl status docker &> /dev/null; then
            green "Docker 安装完成并成功启动！"
        else
            red "Docker 安装完成，但未能成功启动。请检查错误信息。"
            exit 1
        fi
    else
        echo "docker存在，执行安装new-api...."
    fi
}
update_newpai(){
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower -cR
}
#执行安装new-api
new_api(){
    mkdir -p /home/data/new-api
    chmod 777 /home/data/new-api
    chmod 777 /home/data
    docker run --name new-api -d --restart always -p 3000:3000 -e TZ=Asia/Shanghai -v /home/data/new-api:/data calciumion/new-api:latest
}

#添加aws的ipv6地址
add_ipv6(){
    bash <(curl -s https://raw.githubusercontent.com/pulicajexa/test/refs/heads/main/main/aws/ip6.sh)
    }
# 主菜单
main_menu() {
    green "====================================="
    green " 介绍：自定义脚本"
    green " 适用系统：Ubuntu/Debian"
    green "====================================="
    green " 1.安装NY-SG"
    green " 2.安装NY-JP"
    green " 3.安装NY-HK2C"
    green " 4.安装NY-HK4C"
    green " 5.安装NY-C5n.xlarge"
    green " 6.安装NY-USA"
    green " 7.添加ipv6(仅限aws可用)"
    green " 0.退出脚本"
    read -r -p "请输入数字:" num
    case "$num" in
    1)
        ny_SG
        ;;
    2)
        NY_JP
        ;;
    3)  
        NY_HK2C
        ;;
    4)
        NY_HK4C
        ;;
    5)
        NY_C5n
        ;;
    6)
        NY_USA
        ;;
    7)
        add_ipv6
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
main_menu
