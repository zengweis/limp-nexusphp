这是适用于nexusephp的lnmp环境脚本

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

