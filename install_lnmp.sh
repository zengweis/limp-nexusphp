#!/bin/bash

# 设置系统类型
distro=$(lsb_release -is)

# 检查系统类型
if [ "$distro" = "Ubuntu" ]; then
    echo "正在安装 LNMP 环境..."

    # 安装 Nginx
    echo "正在安装 Nginx..."
    sudo apt update
    sudo apt install nginx

    # 配置 Nginx
    echo "正在配置 Nginx..."
    sudo mkdir -p /etc/nginx
    sudo cp /usr/share/nginx/html/index.nginx-debian.html /etc/nginx/
    sudo sed -i 's/index.html index.htm index.nginx-debian.html;/index.php index.html index.htm index.nginx-debian.html;/g' /etc/nginx/nginx.conf

    # 启动 Nginx
    echo "正在启动 Nginx..."
    sudo systemctl enable nginx
    sudo systemctl start nginx

    # 安装 PHP 8.0
    echo "正在安装 PHP 8.0..."
    sudo apt install php8.0 php8.0-cli php8.0-common php8.0-fpm php8.0-mysql php8.0-xml php8.0-mbstring php8.0-curl php8.0-gd php8.0-zip php8.0-bcmath php8.0-intl

    # 配置 PHP-FPM
    echo "正在配置 PHP-FPM..."
    sudo sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g' /etc/php/8.0/fpm/php.ini
    sudo sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/8.0/fpm/php.ini

    # 重启 PHP-FPM
    echo "正在重启 PHP-FPM..."
    sudo systemctl restart php8.0-fpm

    # 安装 MySQL
    echo "正在安装 MySQL..."
    sudo apt update
    sudo apt install mysql-server

    # 配置 MySQL
    echo "正在配置 MySQL..."
    sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '你的密码';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '你的密码';"

    # 重启 MySQL
    echo "正在重启 MySQL..."
    sudo systemctl restart mysql

    # 安装 Redis
    echo "正在安装 Redis..."
    sudo apt update
    sudo apt install redis-server

    # 配置 Redis
    echo "正在配置 Redis..."
    sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
    sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf
    sudo sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf

    # 启动 Redis
    echo "正在启动 Redis..."
    sudo systemctl enable redis-server
    sudo systemctl start redis-server

    # 安装扩展
    echo "正在检查扩展安装..."
    sudo php -m | grep fileinfo
    if [ $? -ne 0 ]; then
        echo "fileinfo 扩展安装失败！"
        sudo apt install php8.0-fileinfo
    fi

    echo "LNMP 环境安装完成！"
else
    echo "不支持当前系统！请检查系统类型！"
fi
