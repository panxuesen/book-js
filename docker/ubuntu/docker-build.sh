#!/bin/bash

# 设置UCloud镜像仓库变量
REGISTRY="uhub.service.ucloud.cn"
# REGISTRY="registry.cn-hangzhou.aliyuncs.com"
BASE_IMAGE_NAME="tojoy"
FINAL_IMAGE_NAME="book-js"
BASE_TAG="base-alpine"
FINAL_TAG="latest-alpine"
FULL_BASE_IMAGE_NAME="${REGISTRY}/${NAMESPACE}/${BASE_IMAGE_NAME}:${BASE_TAG}"
FULL_FINAL_IMAGE_NAME="${REGISTRY}/${NAMESPACE}/${FINAL_IMAGE_NAME}:${FINAL_TAG}"

# 检测当前架构
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  echo "检测到 ARM64 架构 (Apple Silicon M1/M2)"
  PLATFORM_FLAG="--platform=linux/amd64,linux/arm64"
  DOCKER_DEFAULT_PLATFORM="linux/arm64"
else
  echo "检测到 x86_64 架构"
  PLATFORM_FLAG="--platform=linux/amd64"
  DOCKER_DEFAULT_PLATFORM="linux/amd64"
fi

# 设置默认构建平台
export DOCKER_DEFAULT_PLATFORM

echo "开始构建Docker镜像..."
echo "构建平台: $DOCKER_DEFAULT_PLATFORM"

# 构建基础镜像，带有平台标志
echo "===== 构建基础镜像 ====="
docker build $PLATFORM_FLAG -t "${BASE_IMAGE_NAME}:${BASE_TAG}" -f Dockerfile-Base .

if [ $? -ne 0 ]; then
    echo "基础镜像构建失败，退出构建流程"
    exit 1
fi

# 构建最终镜像，使用本地基础镜像
echo "===== 构建最终镜像 ====="
docker build $PLATFORM_FLAG -t "${FINAL_IMAGE_NAME}:${FINAL_TAG}" \
    --build-arg BASE_IMAGE="${BASE_IMAGE_NAME}:${BASE_TAG}" \
    -f Dockerfile .

if [ $? -ne 0 ]; then
    echo "最终镜像构建失败，退出构建流程"
    exit 1
fi

# 给镜像打标签
echo "===== 为镜像打标签 ====="
docker tag "${BASE_IMAGE_NAME}:${BASE_TAG}" "${FULL_BASE_IMAGE_NAME}"
docker tag "${FINAL_IMAGE_NAME}:${FINAL_TAG}" "${FULL_FINAL_IMAGE_NAME}"

# 登录到镜像仓库
echo "===== 登录到镜像仓库 ====="
echo "请输入登录凭证:"
read -p "用户名: " username
read -s -p "密码: " password
echo ""
docker login --username="${username}" --password="${password}" ${REGISTRY}

if [ $? -ne 0 ]; then
    echo "登录失败，退出发布流程"
    exit 1
fi

# 推送镜像到仓库
echo "===== 推送镜像到仓库 ====="
docker push "${FULL_BASE_IMAGE_NAME}"
docker push "${FULL_FINAL_IMAGE_NAME}"

echo "===== 构建和发布完成 ====="
echo "基础镜像: ${FULL_BASE_IMAGE_NAME}"
echo "应用镜像: ${FULL_FINAL_IMAGE_NAME}"

# 清理本地临时镜像（可选）
read -p "是否清理本地构建的临时镜像？(y/n): " clean_images
if [ "$clean_images" == "y" ]; then
    docker rmi "${BASE_IMAGE_NAME}:${BASE_TAG}" "${FINAL_IMAGE_NAME}:${FINAL_TAG}" "${FULL_BASE_IMAGE_NAME}" "${FULL_FINAL_IMAGE_NAME}"
    echo "本地镜像已清理"
fi

echo "提示: 如果您需要在M1 Mac上本地运行此镜像，请在docker-compose.yml中添加 'platform: $DOCKER_DEFAULT_PLATFORM' 配置"

exit 0