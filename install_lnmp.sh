#!/bin/bash

# 获取网站域名
read -p "请输入网站域名: " DOMAIN

# 设置网站根目录
RUN_PATH="/var/www/nexusphp"

# 设置系统类型
distro=$(lsb_release -is)

# 检查系统类型
if [ "$distro" = "Ubuntu" ]; then
    echo "正在安装 LNMP 环境..."

    # 进度条函数
    progress_bar() {
        local -r bar_length=50
        local -r percentage=$1
        local -r progress_bar=$(printf "%${percentage}s" | tr " " "#")
        local -r empty_bar=$(printf "%$(($bar_length - ${#progress_bar}))s" | tr " " " ")
        printf "\r[${progress_bar}${empty_bar}] ${percentage}%%"
    }

    # 获取所有 CPU 核心编号
    cores=$(nproc)

    # 创建 CPU 核心掩码
    core_mask=$(seq 0 $(($cores - 1)) | tr -s ' ' '-' )

    # 使用 taskset 命令运行后续命令
    taskset -c $core_mask  << EOF

    # 更新 apt 并检查安装源
    echo "正在更新 apt 并检查安装源..."
    sudo apt update
    if [ $? -ne 0 ]; then
        echo "更新 apt 失败或无法访问安装源，请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 安装 Nginx
    echo "正在安装 Nginx..."
    sudo apt install -y nginx
    if [ $? -ne 0 ]; then
        echo "安装 Nginx 失败！请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 配置 Nginx
    echo "正在配置 Nginx..."
    sudo mkdir -p "$RUN_PATH"
    sudo cp /usr/share/nginx/html/index.nginx-debian.html "$RUN_PATH/index.html"
    sudo sed -i 's/index.html index.htm index.nginx-debian.html;/index.php index.html index.htm index.nginx-debian.html;/g' /etc/nginx/nginx.conf
    progress_bar 100

    # 启动 Nginx
    echo "正在启动 Nginx..."
    sudo systemctl enable nginx
    sudo systemctl start nginx
    progress_bar 100

    # 安装 PHP 8.0
    echo "正在安装 PHP 8.0..."
    sudo apt install -y php8.0 php8.0-cli php8.0-common php8.0-fpm php8.0-mysql php8.0-xml php8.0-mbstring php8.0-curl php8.0-gd php8.0-zip php8.0-bcmath php8.0-intl
    if [ $? -ne 0 ]; then
        echo "安装 PHP 8.0 失败！请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 配置 PHP-FPM
    echo "正在配置 PHP-FPM..."
    sudo sed -i 's/;cgi.fix_pathinfo=0/cgi.fix_pathinfo=1/g' /etc/php/8.0/fpm/php.ini
    sudo sed -i 's/;opcache.enable=0/opcache.enable=1/g' /etc/php/8.0/fpm/php.ini
    progress_bar 100

    # 重启 PHP-FPM
    echo "正在重启 PHP-FPM..."
    sudo systemctl restart php8.0-fpm
    progress_bar 100

    # 安装 MySQL
    echo "正在安装 MySQL..."
    sudo apt install -y mysql-server
    if [ $? -ne 0 ]; then
        echo "安装 MySQL 失败！请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 配置 MySQL 并设置密码
    echo "正在配置 MySQL..."
    sudo mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'Nexusephp';"
    sudo mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'Nexusephp';"
    progress_bar 100

    # 创建 nexusphp 数据库
    echo "正在创建 nexusphp 数据库..."
    sudo mysql -u root -pNexusephp -e "CREATE DATABASE nexusphp DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
    sudo mysql -u root -pNexusephp -e "GRANT ALL PRIVILEGES ON nexusphp.* TO 'nexusphp'@'localhost' IDENTIFIED BY 'Nexusephp';"
    progress_bar 100

    # 重启 MySQL
    echo "正在重启 MySQL..."
    sudo systemctl restart mysql
    progress_bar 100

    # 安装 Redis
    echo "正在安装 Redis..."
    sudo apt install -y redis-server
    if [ $? -ne 0 ]; then
        echo "安装 Redis 失败！请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 配置 Redis
    echo "正在配置 Redis..."
    sudo cp /etc/redis/redis.conf /etc/redis/redis.conf.bak
    sudo sed -i 's/bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf
    sudo sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf
    progress_bar 100

    # 启动 Redis
    echo "正在启动 Redis..."
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
    progress_bar 100

    # 安装扩展
    echo "正在检查扩展安装..."
    sudo php -m | grep fileinfo
    if [ $? -ne 0 ]; then
        echo "fileinfo 扩展安装失败！"
        sudo apt install -y php8.0-fileinfo
        if [ $? -ne 0 ]; then
            echo "安装 fileinfo 扩展失败！请检查网络连接或安装源配置！"
            exit 1
        fi
    fi
    progress_bar 100

    # 下载 NexusPHP v1.8.11
    echo "正在下载 NexusPHP v1.8.11..."
    wget -nv https://github.com/xiaomlove/nexusphp/archive/refs/tags/v1.8.11.zip -O nexusphp-v1.8.11.zip
    progress_bar 100

    # 解压缩 NexusPHP
    echo "正在解压缩 NexusPHP..."
    unzip nexusphp-v1.8.11.zip -d "$RUN_PATH"
    progress_bar 100

    # 移动解压后的文件夹
    mv "$RUN_PATH/nexusphp-v1.8.11" "$RUN_PATH/nexusphp"
    progress_bar 100

    # 安装 Composer
    echo "正在安装 Composer..."
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php
    php -r "unlink('composer-setup.php');"
    sudo mv composer.phar /usr/local/bin/composer
    progress_bar 100

    # 安装依赖
    echo "正在安装依赖..."
    cd "$RUN_PATH/nexusphp" && composer install
    progress_bar 100

    # 复制安装文件
    echo "正在复制安装文件..."
    cp -R "$RUN_PATH/nexusphp/Install/install" "$RUN_PATH/public/"
    progress_bar 100

    # 设置权限
    echo "正在设置权限..."
    chown -R www-data:www-data "$RUN_PATH"
    progress_bar 100

    # 安装 supervisor
    echo "正在安装 supervisor..."
    sudo apt install -y supervisor
    if [ $? -ne 0 ]; then
        echo "安装 supervisor 失败！请检查网络连接或安装源配置！"
        exit 1
    fi
    progress_bar 100

    # 配置 supervisor
    echo "正在配置 supervisor..."
    sudo sh -c 'echo "[program:nexus-queue]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/nexusphp/artisan queue:work --tries=3 --max-time=3600
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stopwaitsecs=3600
stdout_logfile=/var/log/supervisor/nexus-queue.log" > /etc/supervisor/conf.d/nexus-queue.conf'
    progress_bar 100

    # 启动 supervisor
    echo "正在启动 supervisor..."
    sudo systemctl enable supervisor
    sudo systemctl start supervisor
    progress_bar 100

    # 重新加载 supervisor 配置
    echo "正在重新加载 supervisor 配置..."
    sudo supervisorctl reread
    progress_bar 100

    # 更新 supervisor 进程组
    echo "正在更新 supervisor 进程组..."
    sudo supervisorctl update
    progress_bar 100

    # 启动队列守护进程
    echo "正在启动队列守护进程..."
    sudo supervisorctl start nexus-queue:*
    progress_bar 100

    # 配置 Nginx
    echo "正在配置 Nginx..."
    sudo sh -c 'echo "server {
        root /var/www/nexusphp;
        server_name $DOMAIN;
        location / {
            try_files $uri $uri/ /index.php?$args;
        }
        location ~ \.php$ {
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
        }
        access_log /var/log/nginx/DOMAIN.access.log;
        error_log /var/log/nginx/DOMAIN.error.log;
    }" > /etc/nginx/conf.d/nexusphp.conf'
    progress_bar 100

    # 重启 Nginx
    echo "正在重启 Nginx..."
    sudo systemctl restart nginx
    progress_bar 100

    # 创建定时任务
    echo "正在创建定时任务..."
    sudo crontab -u www-data -e << EOF
* * * * * cd /var/www/nexusphp && php artisan schedule:run >> /var/log/nexusphp/schedule_$DOMAIN.log
* * * * * cd /var/www/nexusphp && php include/cleanup_cli.php >> /var/log/nexusphp/cleanup_cli_$DOMAIN.log
EOF
    progress_bar 100

    echo "LNMP 环境安装完成！"
    echo "MySQL root 密码：Nexusephp"
    echo "NexusPHP 数据库密码：Nexusephp"
    echo "Redis 密码： (空)"
    echo "网站地址：http://$DOMAIN"
    echo "你输入的域名是：$DOMAIN"

EOF

else
    echo "不支持当前系统！请检查系统类型！"
fi
