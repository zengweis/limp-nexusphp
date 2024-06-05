#!/bin/bash

# 检查系统是否为 Debian/Ubuntu
if [ -f /etc/debian_version ]; then
    OS="debian"
elif [ -f /etc/redhat-release ]; then
    OS="redhat"
else
    echo "系统不支持！请确保系统为 Debian/Ubuntu 或 CentOS/RedHat."
    exit 1
fi

# 1. 安装 Nginx 1.25.5
echo "正在安装 Nginx 1.25.5..."
if [ "$OS" == "debian" ]; then
    apt-get update
    apt-get install -y nginx=1.25.5
elif [ "$OS" == "redhat" ]; then
    yum install -y nginx-1.25.5
fi

# 2. 安装 PHP 8.0.26
echo "正在安装 PHP 8.0.26..."
if [ "$OS" == "debian" ]; then
    apt-get install -y php8.0 php8.0-fpm php8.0-mysql php8.0-curl php8.0-mbstring php8.0-xml php8.0-gd php8.0-zip php8.0-intl php8.0-sqlite3 php8.0-fileinfo php8.0-redis php8.0-gmp php8.0-opcache
elif [ "$OS" == "redhat" ]; then
    yum install -y php80w php80w-mysql php80w-curl php80w-mbstring php80w-xml php80w-gd php80w-zip php80w-intl php80w-sqlite3 php80w-fileinfo php80w-redis php80w-gmp php80w-opcache
fi

# 3. 安装 MySQL 5.7.44
echo "正在安装 MySQL 5.7.44..."
if [ "$OS" == "debian" ]; then
    apt-get install -y mysql-server=5.7.44-0ubuntu0.18.04.1
elif [ "$OS" == "redhat" ]; then
    yum install -y mysql-server-5.7.44
fi

# 4. 安装 mysqladmin 5.1
echo "正在安装 mysqladmin 5.1..."
if [ "$OS" == "debian" ]; then
    apt-get install -y mysql-client=5.1.73-1ubuntu1
elif [ "$OS" == "redhat" ]; then
    yum install -y mysql-client-5.1
fi

# 5. 安装 Redis 7.2.4
echo "正在安装 Redis 7.2.4..."
if [ "$OS" == "debian" ]; then
    apt-get update
    apt-get install -y redis-server=7.2.4
elif [ "$OS" == "redhat" ]; then
    yum install -y redis-server-7.2.4
fi

# 6. 配置 Nginx
echo "正在配置 Nginx..."
# 这里需要根据你的实际需求进行修改
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
echo "server {
    listen 80;
    server_name _;
    root /var/www/html;

    index index.html

    location / {
        try_files $uri $uri/ =404;
    }
}
" > /etc/nginx/nginx.conf

# 7. 启动 Nginx 和 Redis
echo "正在启动 Nginx 和 Redis..."
systemctl enable nginx
systemctl start nginx
systemctl enable redis-server
systemctl start redis-server

# 8. 检查扩展安装是否成功
echo "正在检查扩展安装..."
php -m | grep fileinfo > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "fileinfo 扩展已安装."
else
  echo "fileinfo 扩展安装失败！"
  exit 1
fi

php -m | grep redis > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "redis 扩展已安装."
else
  echo "redis 扩展安装失败！"
  exit 1
fi

php -m | grep gmp > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "gmp 扩展已安装."
else
  echo "gmp 扩展安装失败！"
  exit 1
fi

php -m | grep opcache > /dev/null 2>&1
if [[ $? -eq 0 ]]; then
  echo "opcache 扩展已安装."
else
  echo "opcache 扩展安装失败！"
  exit 1
fi

echo "安装完成！"