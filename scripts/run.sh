#!/bin/bash

# Flagr 后端服务运行脚本
# 使用方法: ./scripts/run.sh [选项]
# 选项:
#   --dev       开发模式（SQLite 内存数据库）
#   --demo      演示模式（使用示例 SQLite 数据库）
#   --mysql     使用 MySQL 数据库
#   --postgres  使用 PostgreSQL 数据库
#   --help      显示帮助信息

set -e

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
HOST="0.0.0.0"
PORT="18000"
DB_DRIVER="sqlite3"
DB_CONNECTION="flagr.sqlite"
BUILD_FIRST=true

# 显示帮助信息
show_help() {
    echo "Flagr 后端服务运行脚本"
    echo ""
    echo "使用方法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  --dev          开发模式（使用 SQLite 内存数据库）"
    echo "  --demo         演示模式（使用示例 SQLite 数据库）"
    echo "  --mysql        使用 MySQL 数据库"
    echo "  --postgres     使用 PostgreSQL 数据库"
    echo "  --port PORT    指定端口（默认: 18000）"
    echo "  --no-build     跳过构建步骤"
    echo "  --help         显示此帮助信息"
    echo ""
    echo "环境变量:"
    echo "  FLAGR_DB_DBDRIVER          数据库驱动 (sqlite3/mysql/postgres)"
    echo "  FLAGR_DB_DBCONNECTIONSTR   数据库连接字符串"
    echo "  FLAGR_RECORDER_ENABLED     启用数据记录 (true/false)"
    echo "  FLAGR_CORS_ENABLED         启用 CORS (true/false)"
    echo "  FLAGR_PROMETHEUS_ENABLED   启用 Prometheus 指标 (true/false)"
    echo ""
    echo "示例:"
    echo "  $0 --dev                    # 开发模式运行"
    echo "  $0 --demo                   # 演示模式运行"
    echo "  $0 --mysql --port 8080      # 使用 MySQL 在端口 8080 运行"
    echo ""
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev)
            DB_DRIVER="sqlite3"
            DB_CONNECTION=":memory:"
            shift
            ;;
        --demo)
            DB_DRIVER="sqlite3"
            DB_CONNECTION="/data/demo_sqlite3.db"
            # 确保演示数据库存在
            mkdir -p /data
            if [ ! -f "/data/demo_sqlite3.db" ]; then
                cp "$PROJECT_ROOT/buildscripts/demo_sqlite3.db" "/data/demo_sqlite3.db" 2>/dev/null || echo "${YELLOW}警告: 演示数据库不存在，将创建新的数据库${NC}"
            fi
            shift
            ;;
        --mysql)
            DB_DRIVER="mysql"
            DB_CONNECTION="${MYSQL_CONNECTION:-root:@tcp(127.0.0.1:3306)/flagr?parseTime=true}"
            shift
            ;;
        --postgres)
            DB_DRIVER="postgres"
            DB_CONNECTION="${POSTGRES_CONNECTION:-postgres://postgres:postgres@localhost:5432/flagr?sslmode=disable}"
            shift
            ;;
        --port)
            PORT="$2"
            shift 2
            ;;
        --no-build)
            BUILD_FIRST=false
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "${RED}未知选项: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 检查 Go 环境
check_go() {
    if ! command -v go &> /dev/null; then
        echo "${RED}错误: 未找到 Go 环境，请先安装 Go${NC}"
        exit 1
    fi
    echo "${GREEN}Go 版本: $(go version)${NC}"
}

# 构建项目
build_project() {
    echo "${BLUE}正在构建 Flagr 服务...${NC}"

    # 安装依赖
    go mod download

    # 生成 Swagger 代码（如果需要）
    if [ -f "docs/api_docs/bundle.yaml" ]; then
        echo "${BLUE}生成 Swagger 代码...${NC}"
        make gen 2>/dev/null || echo "${YELLOW}跳过 Swagger 生成${NC}"
    fi

    # 构建二进制文件
    CGO_ENABLED=0 go build -o "$PROJECT_ROOT/flagr" github.com/openflagr/flagr/swagger_gen/cmd/flagr-server

    echo "${GREEN}构建完成: $PROJECT_ROOT/flagr${NC}"
}

# 运行服务
run_server() {
    echo "${BLUE}启动 Flagr 服务...${NC}"
    echo "${GREEN}服务地址: http://localhost:${PORT}${NC}"
    echo "${GREEN}API 文档: http://localhost:${PORT}/api/v1${NC}"
    echo "${GREEN}健康检查: http://localhost:${PORT}/api/v1/health${NC}"
    echo ""

    export HOST
    export PORT
    export FLAGR_DB_DBDRIVER="$DB_DRIVER"
    export FLAGR_DB_DBCONNECTIONSTR="$DB_CONNECTION"

    # 运行服务
    "$PROJECT_ROOT/flagr"
}

# 主流程
main() {
    echo "${BLUE}========================================${NC}"
    echo "${BLUE}       Flagr 后端服务启动脚本${NC}"
    echo "${BLUE}========================================${NC}"
    echo ""

    check_go

    if [ "$BUILD_FIRST" = true ]; then
        build_project
    else
        if [ ! -f "$PROJECT_ROOT/flagr" ]; then
            echo "${RED}错误: 未找到编译后的文件，请先运行构建${NC}"
            exit 1
        fi
    fi

    echo ""
    echo "${YELLOW}配置信息:${NC}"
    echo "  数据库驱动: $DB_DRIVER"
    echo "  数据库连接: $DB_CONNECTION"
    echo "  服务端口: $PORT"
    echo ""

    run_server
}

main