#!/bin/bash

# 安装依赖（针对Ubuntu）
install_dependencies() {
    sudo apt update
    sudo apt install -y curl wget docker.io docker-compose
}

# 下载Fractal Bitcoin并安装
install_fractal_bitcoin() {
    # 创建安装目录
    mkdir -p ~/fractal-bitcoin
    cd ~/fractal-bitcoin

    # 下载最新版本的Fractal Bitcoin
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.2.1/fractald-0.2.1-x86_64-linux-gnu.tar.gz

    # 解压文件
    tar -xvf fractald-0.2.1-x86_64-linux-gnu.tar.gz

    # 配置权限
    chmod +x fractald-0.2.1/bin/*
}

# 启动节点
start_node() {
    cd ~/fractal-bitcoin/fractald-0.2.1/bin
    ./fractald --daemon
}

# 主菜单
echo "1. 安装依赖环境"
echo "2. 安装Fractal Bitcoin"
echo "3. 启动节点"
read -p "选择操作: " choice

case $choice in
    1) install_dependencies ;;
    2) install_fractal_bitcoin ;;
    3) start_node ;;
    *) echo "无效选择" ;;
esac
