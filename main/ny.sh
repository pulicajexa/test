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
  bash <(curl -fLSs https://api.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-o -t 26f7e5b2-48dc-41aa-988d-29aa12017d18 -u https://ny.plu.lol"
}

#NY-JP
NY_JP(){
  bash <(curl -fLSs https://api.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-o -t 0143f3c2-6976-4bcd-97a1-7ce161a63d1c -u https://ny.plu.lol"
}

#NY-HK-2C
NY_HK2C(){
  bash <(curl -fLSs https://api.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-o -t ce683d7b-c764-4904-b7f4-d24364f20b11 -u https://ny.plu.lol"
}
#NY-HK-4C
NY_HK4C(){
  bash <(curl -fLSs https://api.nyafw.com/download/nyanpass-install.sh) rel_nodeclient "-o -t 97025562-d197-4a07-b669-28224aa39b25 -u https://ny.plu.lol"
}


# 主菜单
main_menu() {
    green "====================================="
    green " 介绍：自定义脚本"
    green " 系统：Ubuntu/Debian/CentOS"
    green "====================================="
    green " 1.安装NY-SG"
    green " 2.安装NY-JP"
    green " 3.安装NY-HK2C"
    green " 4.安装NY-HK4C"
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
