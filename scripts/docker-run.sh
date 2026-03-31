#!/bin/bash

# Flagr Docker 运行脚本

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

PORT="${1:-18000}"

echo "🐳 使用 Docker 运行 Flagr..."
echo ""
echo "步骤:"
echo "1. 构建 Docker 镜像"
echo "2. 运行容器"
echo ""

# 构建镜像
echo "📦 构建 Docker 镜像..."
docker build -t flagr:local .

# 运行容器
echo ""
echo "🚀 启动容器..."
docker run -d \
    --name flagr \
    -p ${PORT}:18000 \
    -e FLAGR_DB_DBDRIVER=sqlite3 \
    -e FLAGR_DB_DBCONNECTIONSTR=/data/flagr.db \
    -v flagr_data:/data \
    flagr:local

echo ""
echo "✅ Flagr 已启动!"
echo "📍 服务地址: http://localhost:${PORT}"
echo ""
echo "常用命令:"
echo "  查看日志: docker logs -f flagr"
echo "  停止服务: docker stop flagr"
echo "  删除容器: docker rm flagr"