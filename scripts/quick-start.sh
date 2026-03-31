#!/bin/bash

# Flagr 快速启动脚本（开发环境）
# 一键构建并运行 Flagr 服务

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🚀 Flagr 快速启动..."

# 检查 Go
if ! command -v go &> /dev/null; then
    echo "❌ 错误: 未找到 Go 环境"
    exit 1
fi

# 构建后端
echo "📦 构建后端服务..."
CGO_ENABLED=0 go build -o flagr github.com/openflagr/flagr/swagger_gen/cmd/flagr-server

# 构建前端（如果需要）
if [ ! -d "browser/flagr-ui/dist" ]; then
    echo "📦 构建前端..."
    cd browser/flagr-ui
    npm install --silent
    npm run build
    cd "$PROJECT_ROOT"
fi

# 设置环境变量
export HOST=0.0.0.0
export PORT=18000
export FLAGR_DB_DBDRIVER=sqlite3
export FLAGR_DB_DBCONNECTIONSTR=flagr_dev.db
export FLAGR_RECORDER_ENABLED=false

echo ""
echo "✅ 启动服务..."
echo "📍 服务地址: http://localhost:18000"
echo ""

./flagr