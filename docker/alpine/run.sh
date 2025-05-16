#!/bin/sh

# 在Alpine中更推荐使用/bin/sh而不是bash

# 启动dbus守护进程（如果不存在）
if [ ! -e /var/run/dbus/pid ] || ! pgrep -f "dbus-daemon" > /dev/null; then
  echo "正在启动dbus守护进程..."
  dbus-daemon --system --fork
else
  echo "dbus守护进程已经在运行"
fi

# 获取脚本所在目录
SCRIPT_PATH=$(cd $(dirname "$0"); pwd)
cd "${SCRIPT_PATH}"

# 创建必要的目录（添加错误处理）
for DIR in ./public/fonts ./public/pdf ./public/img; do
  if [ ! -d "$DIR" ]; then
    echo "创建目录: $DIR"
    mkdir -p "$DIR" || { echo "无法创建目录 $DIR"; exit 1; }
  fi
done

# 设置字体安装脚本的执行权限并运行
if [ -f ./install-font.sh ]; then
  chmod 755 ./install-font.sh
  echo "运行字体安装脚本..."
  ./install-font.sh || echo "警告: 字体安装可能未成功完成"
else
  echo "警告: 未找到字体安装脚本"
fi

# 显示系统信息
echo "------系统信息------"
echo "NODE_ENV: $NODE_ENV"
echo "RUN_ENV: $RUN_ENV"
echo "MAX_BROWSER: $MAX_BROWSER"
echo "---------------------"

# 启动应用程序
echo "启动应用程序..."
exec yarn start
