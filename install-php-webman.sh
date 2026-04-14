#!/bin/bash

# 获取当前执行目录
INSTALL_DIR=$(pwd)

# 设置默认webman目录名
WEBMAN_DIR_NAME="web"

# 提示用户输入目录名
read -p "请输入webman项目目录名（直接回车使用默认'web'）: " WEBMAN_DIR_INPUT

if [ -n "$WEBMAN_DIR_INPUT" ]; then
    WEBMAN_DIR_NAME="$WEBMAN_DIR_INPUT"
fi

WEBMAN_DIR="$INSTALL_DIR/$WEBMAN_DIR_NAME"
VENV_DIR="$WEBMAN_DIR/venv"
BIN_DIR="$VENV_DIR/bin"
PHP_INI_DIR="$VENV_DIR/etc/php"

# 检查webman目录是否已存在
if [ -d "$WEBMAN_DIR" ]; then
    read -p "目录 '$WEBMAN_DIR_NAME' 已存在。是否删除并重新安装？(y/n): " choice
    if [ "$choice" == "y" ]; then
        rm -rf "$WEBMAN_DIR"
        echo "已删除旧目录"
    else
        echo "取消安装。"
        exit 0
    fi
fi

echo "安装目录: $INSTALL_DIR"
echo "Webman项目目录: $WEBMAN_DIR"
echo "虚拟环境目录: $VENV_DIR"
echo "二进制目录: $BIN_DIR"

# 检查文件是否存在并提示覆盖
check_and_prompt() {
    local file_path=$1
    local file_name=$2

    if [ -f "$file_path" ]; then
        read -p "$file_name 已存在。是否覆盖？(y/n): " choice
        if [ "$choice" != "y" ]; then
            echo "跳过 $file_name 安装。"
            return 1
        fi
    fi
    return 0
}

# 检查系统架构
ARCH=$(uname -m)
OS=$(uname -s)

case "$ARCH" in
    x86_64)
        ARCH_SUFFIX="x86_64"
        ;;
    aarch64)
        ARCH_SUFFIX="aarch64"
        ;;
    arm64)
        ARCH_SUFFIX="aarch64"
        ;;
    *)
        echo "不支持的架构: $ARCH"
        exit 1
        ;;
esac

case "$OS" in
    Linux)
        OS_SUFFIX="linux"
        ;;
    Darwin)
        OS_SUFFIX="mac"
        ;;
    *)
        echo "不支持的操作系统: $OS"
        exit 1
        ;;
esac

# 设置默认PHP版本为8.3（8.4的mac版本不存在）
PHP_VERSION="8.3"

# 提示用户，直接回车使用默认版本
read -p "请输入要安装的PHP版本 (8.1-8.3，直接回车使用默认8.3): " PHP_VERSION_INPUT

# 如果用户输入了内容，则使用用户输入的版本
if [ -n "$PHP_VERSION_INPUT" ]; then
    PHP_VERSION="$PHP_VERSION_INPUT"
fi

# 验证版本号
if [[ ! "$PHP_VERSION" =~ ^8\.[1-3]$ ]]; then
    echo "无效的PHP版本: $PHP_VERSION"
    exit 1
fi

echo "将安装PHP版本: $PHP_VERSION"

# 构造下载链接
PHP_FILENAME="php-$PHP_VERSION-$OS_SUFFIX-$ARCH_SUFFIX.tar.gz"
PHP_URL="https://download.workerman.net/php/$PHP_FILENAME"

# 验证下载链接是否存在
echo "验证PHP下载链接..."
HTTP_CODE=$(curl -sI "$PHP_URL" 2>/dev/null | head -1 | awk '{print $2}')
if [ "$HTTP_CODE" != "200" ]; then
    echo "错误: PHP $PHP_VERSION 的 ${OS_SUFFIX}-${ARCH_SUFFIX} 版本不存在 (HTTP $HTTP_CODE)"
    echo "请选择其他版本"
    exit 1
fi

# 使用临时目录安装PHP/Composer
TEMP_INSTALL_DIR=$(mktemp -d)
TEMP_BIN="$TEMP_INSTALL_DIR/bin"
mkdir -p "$TEMP_BIN"

PHP_BIN="$TEMP_BIN/php"
COMPOSER_BIN="$TEMP_BIN/composer"

# 检查并提示覆盖PHP
if check_and_prompt "$BIN_DIR/php" "PHP"; then
    # 下载并安装PHP
    echo "下载PHP..."
    curl -# "$PHP_URL" -o "$PHP_FILENAME"
    if [ $? -ne 0 ]; then
        echo "下载失败: $PHP_URL"
        exit 1
    fi

    # 解压到临时目录
    TEMP_DIR=$(mktemp -d)
    tar -xf "$PHP_FILENAME" -C "$TEMP_DIR"
    
    # 移动php二进制文件到bin目录
    mv "$TEMP_DIR/php" "$PHP_BIN"
    chmod +x "$PHP_BIN"
    
    # 清理临时文件
    rm -rf "$TEMP_DIR"
    rm -f "$PHP_FILENAME"
    
    echo "PHP已安装到: $PHP_BIN"
fi

# 生成临时的 php.ini
TEMP_PHP_INI_DIR="$TEMP_INSTALL_DIR/etc/php"
mkdir -p "$TEMP_PHP_INI_DIR"
TEMP_PHP_INI="$TEMP_PHP_INI_DIR/php.ini"
TEMP_CA_CERT="$TEMP_INSTALL_DIR/ca-certificates.crt"

echo "创建临时php.ini"
cat <<EOL > "$TEMP_PHP_INI"
openssl.cafile=$TEMP_CA_CERT
opcache.enable=1
opcache.enable_cli=1
opcache.jit=tracing
opcache.jit_buffer_size=32M
apc.enable_cli=1
memory_limit=256M
EOL

# 下载并安装Composer到临时目录
echo "安装Composer..."
curl -# -o "$COMPOSER_BIN" https://download.workerman.net/php/composer.phar
if [ $? -ne 0 ]; then
    echo "下载Composer失败"
    exit 1
fi

chmod +x "$COMPOSER_BIN"
echo "Composer已安装到: $COMPOSER_BIN"

# 下载 CA 证书到临时目录
echo "下载证书..."
curl -#o "$TEMP_CA_CERT" https://download.workerman.net/php/ca-certificates.crt
if [ $? -eq 0 ]; then
    echo "CA 证书已下载"
else
    echo "下载 CA 证书失败"
    exit 1
fi

echo ""
echo "正在安装webman项目到 $WEBMAN_DIR ..."

# 设置环境变量允许root运行composer并启用插件
export COMPOSER_ALLOW_SUPERUSER=1

# 设置composer使用我们安装的PHP版本
export COMPOSER_PHP="$PHP_BIN"

# 重置composer仓库配置（避免镜像问题）
"$PHP_BIN" "$COMPOSER_BIN" config -g --unset repos.packagist

# 使用指定的PHP版本运行composer创建项目
"$PHP_BIN" -c "$TEMP_PHP_INI" "$COMPOSER_BIN" create-project workerman/webman:~2.0 "$WEBMAN_DIR" --no-interaction

# webman安装完成后，安装webman/console
echo ""
echo "正在安装webman/console..."
cd "$WEBMAN_DIR"
"$PHP_BIN" "$COMPOSER_BIN" require webman/console --no-interaction

# 安装webman/database
echo ""
echo "正在安装webman/database..."
"$PHP_BIN" "$COMPOSER_BIN" require -W webman/database --no-interaction

# 安装webman/redis和illuminate/events
echo ""
echo "正在安装webman/redis illuminate/events..."
"$PHP_BIN" "$COMPOSER_BIN" require -W webman/redis illuminate/events --no-interaction

# 将PHP/Composer移动到项目venv目录
echo ""
echo "正在配置项目环境..."
mkdir -p "$BIN_DIR"
mkdir -p "$PHP_INI_DIR"

# 移动PHP二进制文件
mv "$PHP_BIN" "$BIN_DIR/php"
chmod +x "$BIN_DIR/php"

# 移动Composer
mv "$COMPOSER_BIN" "$BIN_DIR/composer"
chmod +x "$BIN_DIR/composer"

# 移动CA证书
mv "$TEMP_CA_CERT" "$VENV_DIR/ca-certificates.crt"

# 生成正式的php.ini
cat <<EOL > "$PHP_INI_DIR/php.ini"
openssl.cafile=$VENV_DIR/ca-certificates.crt
opcache.enable=1
opcache.enable_cli=1
opcache.jit=tracing
opcache.jit_buffer_size=32M
apc.enable_cli=1
memory_limit=256M
EOL

# 清理临时目录
rm -rf "$TEMP_INSTALL_DIR"

# 更新路径变量
PHP_BIN="$BIN_DIR/php"
COMPOSER_BIN="$BIN_DIR/composer"

echo "环境配置完成"

# 创建webman项目的.gitignore（添加venv到忽略列表）
if ! grep -q "^/venv/$" "$WEBMAN_DIR/.gitignore" 2>/dev/null; then
    echo "/venv/" >> "$WEBMAN_DIR/.gitignore"
fi

echo ""
echo "========================================"
echo "安装完成！"
echo "========================================"
echo ""
echo "启动webman: $PHP_BIN -c $PHP_INI_DIR/php.ini $WEBMAN_DIR_NAME/start.php start"
echo ""

# 自动追加到.bashrc
BASHRC="$HOME/.bashrc"
ROUTER_CODE='_webman_find_venv() { local dir="$1"; while [ "$dir" != "/" ]; do [ -f "$dir/venv/bin/php" ] && { echo "$dir/venv"; return 0; }; dir=$(dirname "$dir"); done; return 1; }
php() { local v=$(_webman_find_venv "$(pwd)"); [ -n "$v" ] && { export PHPRC="$v/etc/php"; "$v/bin/php" "$@"; } || command php "$@"; }
composer() { local v=$(_webman_find_venv "$(pwd)"); [ -n "$v" ] && { export PHPRC="$v/etc/php"; export COMPOSER_PHP="$v/bin/php"; "$v/bin/php" "$v/bin/composer" "$@"; } || command composer "$@"; }'

# 检查是否已存在
if ! grep -q "_webman_find_venv" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# webman PHP/Composer自动路由" >> "$BASHRC"
    echo "$ROUTER_CODE" >> "$BASHRC"
    echo "已自动添加到 $BASHRC"
    echo "请运行: source $BASHRC"
else
    echo "自动路由代码已存在于 $BASHRC"
fi

echo ""
echo "========================================"
