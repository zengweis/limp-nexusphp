#!/bin/bash

# 检查系统是否已经安装了nginx、mysql和php
if [ ! -e /usr/local/nginx ]; then
    # 安装nginx
    apt-get update
    apt-get install -y nginx
fi

if [ ! -e /usr/local/mysql ]; then
    # 安装mysql
    apt-get install -y mysql-server
fi


# 配置nginx
cp /etc/nginx/sites-available/default /etc/nginx/sites-available/lnmp
sed -i "s/listen\s*80;/listen\s*80;\n    server_name your_domain.com;/g" /etc/nginx/sites-available/lnmp
sed -i "s/root\s*\/var\/www\/html;/root\s*\/usr\/share\/nginx\/html;/g" /etc/nginx/sites-available/lnmp
sed -i "s/index\s*index.html;/index\s*index.php index.html index.htm;/g" /etc/nginx/sites-available/lnmp
systemctl restart nginx

# 配置mysql
mysql_secure_installation

# 安装 PHP 8.0
apt install php8.1-cli

# 安装fileinfo扩展
sudo apt-get update
sudo apt-get install php-fileinfo

# 安装redis扩展
sudo apt-get install redis-server

# 安装gmp扩展
sudo apt-get install php-gmp

# 安装opcache扩展
sudo apt-get install php-opcache

# 重启php-fpm服务以使新安装的扩展生效
sudo service php8.1-fpm restart

# 检查 PHP 版本和已安装扩展
php -v
sudo systemctl status php8.1-fpm

echo "LNMP环境安装完成！"
