#!/bin/bash

# 安装依赖环境（针对Ubuntu）
install_env_and_full_node_ubuntu() {
    # 更新包管理器并安装依赖
    sudo apt update
    sudo apt install -y curl wget jq git make nodejs npm docker.io docker-compose

    # 安装yarn
    sudo npm install -g yarn

    install_and_build_cat
}

# 安装并构建 CAT Token Box
install_and_build_cat() {
    git clone https://github.com/CATProtocol/cat-token-box
    cd cat-token-box
    yarn install
    yarn build
    cd ./packages/tracker/
    chmod 777 docker/data docker/pgdata
    docker-compose up -d
    cd ../../
    docker build -t tracker:latest .
    docker run -d \
        --name tracker \
        --add-host="host.docker.internal:host-gateway" \
        -e DATABASE_HOST="host.docker.internal" \
        -e RPC_HOST="host.docker.internal" \
        -p 3000:3000 \
        tracker:latest
    # 配置JSON文件
    echo '{
        "network": "fractal-mainnet",
        "tracker": "http://127.0.0.1:3000",
        "dataDir": ".",
        "maxFeeRate": 30,
        "rpc": {
            "url": "http://127.0.0.1:8332",
            "username": "bitcoin",
            "password": "opcatAwesome"
        }
    }' > ~/cat-token-box/packages/cli/config.json
    # 创建mint脚本
    echo '#!/bin/bash
    command="yarn cli mint -i 45ee725c2c5993b3e4d308842d87e973bf1951f5f7a804b21e4dd964ecd12d6b_0 5"
    while true; do
        $command
        if [ $? -ne 0 ]; then
            echo "命令执行失败，退出循环"
            exit 1
        fi
        sleep 1
    done' > ~/cat-token-box/packages/cli/mint_script.sh
    chmod +x ~/cat-token-box/packages/cli/mint_script.sh
}

# 创建钱包
create_wallet() {
    echo -e "\n"
    cd ~/cat-token-box/packages/cli
    yarn cli wallet create
    echo -e "\n"
    yarn cli wallet address
    echo -e "请保存上面创建好的钱包地址、助记词"
}

# 启动 mint 并设置 gas 费用
start_mint_cat() {
    read -p "请输入想要mint的gas: " newMaxFeeRate
    sed -i "s/\"maxFeeRate\": [0-9]*/\"maxFeeRate\": $newMaxFeeRate/" ~/cat-token-box/packages/cli/config.json
    cd ~/cat-token-box/packages/cli
    bash ~/cat-token-box/packages/cli/mint_script.sh
}

# 查看节点同步日志
check_node_log() {
    docker logs -f --tail 100 tracker
}

# 查看钱包余额
check_wallet_balance() {
    cd ~/cat-token-box/packages/cli
    yarn cli wallet balances
}

# 显示主菜单
echo -e "
1. 安装依赖环境和全节点
2. 创建钱包
3. 开始 mint cat
4. 查看节点同步日志
5. 查看钱包余额
"

# 获取用户选择并执行相应操作
read -e -p "请输入您的选择: " num

case $num in
    1)
        install_env_and_full_node_ubuntu
        ;;
    2)
        create_wallet
        ;;
    3)
        start_mint_cat
        ;;
    4)
        check_node_log
        ;;
    5)
        check_wallet_balance
        ;;
    *)
        echo "无效选择"
        ;;
esac
