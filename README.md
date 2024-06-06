这是适用于nexusephp的lnmp环境脚本
执行完毕上传nexusephp代码，创建sql  
mysql进入后create database `nexusphp` default charset=utf8mb4 collate utf8mb4_general_ci;
配置web http，打开nginx 配置目录（一般为 /etc/nginx/conf.d/）下新增一个 nexusphp.conf

输入配置，记得按实际更改
server {

    # 以实际为准
    root /RUN_PATH; 

    server_name DOMAIN;

    location / {
        index index.html index.php;
        try_files $uri $uri/ /nexus.php$is_args$args;
    }

    # Filament
    location ^~ /filament {
        try_files $uri $uri/ /nexus.php$is_args$args;
    }

    location ~ \.php {
        # 以实际为准
        fastcgi_pass 127.0.0.1:9000; 
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    access_log /var/log/nginx/DOMAIN.access.log;
    error_log /var/log/nginx/DOMAIN.error.log;
}




若启用https

启用 https，首先得准备好证书（参见下方 [关于 https]）。

server {
    listen 443 ssl;
    ssl_certificate /SOME/PATH/DOMAIN.pem;
    ssl_certificate_key /SOME/PATH/DOMAIN.key;

    # 以实际为准
    root /RUN_PATH; 

    server_name DOMAIN;

    location / {
        index index.html index.php;
        try_files $uri $uri/ /nexus.php$is_args$args;
    }

    # Filament
    location ^~ /filament {
        try_files $uri $uri/ /nexus.php$is_args$args;
    }

    location ~ \.php {
        # 以实际为准
        fastcgi_pass 127.0.0.1:9000; 
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    access_log /var/log/nginx/DOMAIN.access.log;
    error_log /var/log/nginx/DOMAIN.error.log;
}
# http 跳转 https
server {
    if ($host = DOMAIN) {
        return 301 https://$host$request_uri;
    }
    server_name DOMAIN;
    listen 80;
    return 404;
}

配置完重载nginx



在root_path下composer install之后cp -R nexus/Install/install public/，复制 nexus/Install/install 到 public/，保证最后 public/install/install.php 存在
chown -R PHP_USER:PHP_USER ROOT_PATH，设置根目录所有者为运行 PHP 的用户



如果安装fileinfo出错，可能是没有正确的软件源导致，请使用
sudo apt update
sudo add-apt-repository ppa:ondrej/php
sudo apt update
然后尝试再次安装 php8.0-fileinfo：
sudo apt install php8.0-fileinfo


PHP出错
sudo add-apt-repository ppa:ondrej/php
sudo apt update
若无法找到 libssl 软件包，使用
sudo apt install libssl-dev

