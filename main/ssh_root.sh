#!/bin/bash

# 检查 sudo 权限
if ! sudo -l >/dev/null; then
    echo "当前用户没有足够的权限执行 sudo 命令。"
    exit 1
fi

# 输入并确认密码
read -r -s -p "请输入要设置的root密码: " passwdroot
echo  # 输出一个换行
read -r -s -p "请确认您的密码: " passwdroot_2
echo
if [ "$passwdroot" != "$passwdroot_2" ]; then
    echo "两次输入的密码不匹配。"
    exit 1
fi

# 一键更改root密码
echo "root:$passwdroot" | chpasswd
if [ $? -ne 0 ]; then
    echo "更改root密码失败"
    exit 1
fi


# 修改 SSH 配置允许 root 登录
sudo sed -i 's/^.*PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
sudo sed -i 's/^.*PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config

# 重启 SSH 服务
sudo service sshd restart
if [ $? -ne 0 ]; then
    echo "SSH服务重启失败"
    exit 1
fi

echo "SSH 配置已更新，root 用户现在可以使用密码登录。"
