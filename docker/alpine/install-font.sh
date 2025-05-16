#!/bin/sh

# 在Alpine中更推荐使用/bin/sh而不是bash
# 获取脚本所在目录
SCRIPT_PATH=$(cd $(dirname "$0"); pwd)
cd "${SCRIPT_PATH}"

echo "#################### START INSTALL FONTS #####################"

# 检查目录是否存在，并复制字体文件
if [ -d ./public/fonts ]; then
  # 设置适当的权限
  chmod -R 755 ./public/fonts
  
  # 检查目标目录是否存在
  if [ ! -d /usr/share/fonts/custom ]; then
    mkdir -p /usr/share/fonts/custom
  fi
  
  # 复制字体文件到自定义目录而不是系统目录
  cp -rf ./public/fonts/. /usr/share/fonts/custom/
  
  # 重建字体缓存，添加-v参数以显示更详细的信息
  fc-cache -rfv
  
  echo "字体安装完成，已安装的字体列表："
  fc-list | grep -i custom
else
  echo "未找到字体目录 ./public/fonts"
fi

echo "####################  END INSTALL FONTS  #####################"