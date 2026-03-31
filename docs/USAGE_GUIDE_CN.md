# Flagr 使用手册

## 目录

1. [简介](#简介)
2. [环境要求](#环境要求)
3. [快速开始](#快速开始)
4. [安装方式](#安装方式)
5. [配置说明](#配置说明)
6. [API 使用](#api-使用)
7. [前端界面](#前端界面)
8. [数据库配置](#数据库配置)
9. [生产部署](#生产部署)
10. [常见问题](#常见问题)

---

## 简介

Flagr 是一个开源的功能标志（Feature Flag）、A/B 测试和动态配置微服务。它提供了：

- **功能标志管理**：动态开启/关闭功能
- **A/B 测试**：支持多种变体分配策略
- **动态配置**：运行时修改配置
- **RESTful API**：完善的 API 接口
- **Web 管理界面**：直观的图形化管理

---

## 环境要求

### 后端要求

- **Go**: 1.26 或更高版本
- **数据库**（可选）:
  - SQLite 3（开发环境推荐）
  - MySQL 5.7+
  - PostgreSQL 12+

### 前端要求

- **Node.js**: 16.x 或更高版本
- **npm**: 8.x 或更高版本

### 容器化部署

- **Docker**: 20.x 或更高版本
- **Docker Compose**（可选）

---

## 快速开始

### 方式一：使用快速启动脚本

```bash
# 克隆项目
git clone https://github.com/openflagr/flagr.git
cd flagr

# 运行快速启动脚本
./scripts/quick-start.sh
```

服务启动后访问：http://localhost:18000

### 方式二：使用 Docker

```bash
# 拉取官方镜像
docker pull ghcr.io/openflagr/flagr

# 运行容器
docker run -d -p 18000:18000 ghcr.io/openflagr/flagr

# 或使用本地构建
./scripts/docker-run.sh
```

### 方式三：手动构建运行

```bash
# 安装依赖
go mod download

# 构建后端
make build

# 构建前端
make build_ui

# 运行服务
./flagr --port 18000
```

---

## 安装方式

### 1. 本地开发环境

```bash
# 使用开发模式运行（内存数据库）
./scripts/run.sh --dev

# 使用 SQLite 文件数据库
./scripts/run.sh --demo

# 指定端口
./scripts/run.sh --port 8080
```

### 2. MySQL 数据库

```bash
# 设置 MySQL 连接
export FLAGR_DB_DBDRIVER=mysql
export FLAGR_DB_DBCONNECTIONSTR="root:password@tcp(127.0.0.1:3306)/flagr?parseTime=true"

# 或使用脚本
./scripts/run.sh --mysql
```

### 3. PostgreSQL 数据库

```bash
# 设置 PostgreSQL 连接
export FLAGR_DB_DBDRIVER=postgres
export FLAGR_DB_DBCONNECTIONSTR="postgres://user:password@localhost:5432/flagr?sslmode=disable"

# 或使用脚本
./scripts/run.sh --postgres
```

### 4. Docker 部署

```bash
# 构建并运行
./scripts/docker-run.sh

# 或手动操作
docker build -t flagr:local .
docker run -d -p 18000:18000 flagr:local
```

---

## 配置说明

### 环境变量配置

Flagr 支持通过环境变量进行配置，主要配置项如下：

#### 基础配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `HOST` | 服务监听地址 | `localhost` |
| `PORT` | 服务监听端口 | `18000` |

#### 数据库配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_DB_DBDRIVER` | 数据库驱动 (sqlite3/mysql/postgres) | `sqlite3` |
| `FLAGR_DB_DBCONNECTIONSTR` | 数据库连接字符串 | `flagr.sqlite` |

#### 日志配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_LOGRUS_LEVEL` | 日志级别 | `info` |
| `FLAGR_LOGRUS_FORMAT` | 日志格式 (text/json) | `text` |

#### CORS 配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_CORS_ENABLED` | 启用 CORS | `true` |
| `FLAGR_CORS_ALLOWED_ORIGINS` | 允许的来源 | `*` |

#### 数据记录配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_RECORDER_ENABLED` | 启用数据记录 | `false` |
| `FLAGR_RECORDER_TYPE` | 记录类型 (kafka/kinesis/pubsub) | `kafka` |

#### Prometheus 配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_PROMETHEUS_ENABLED` | 启用 Prometheus 指标 | `false` |
| `FLAGR_PROMETHEUS_PATH` | 指标路径 | `/metrics` |

#### 认证配置

| 环境变量 | 说明 | 默认值 |
|---------|------|--------|
| `FLAGR_JWT_AUTH_ENABLED` | 启用 JWT 认证 | `false` |
| `FLAGR_JWT_AUTH_SECRET` | JWT 密钥 | - |
| `FLAGR_BASIC_AUTH_ENABLED` | 启用 Basic 认证 | `false` |
| `FLAGR_BASIC_AUTH_USERNAME` | Basic 认证用户名 | - |
| `FLAGR_BASIC_AUTH_PASSWORD` | Basic 认证密码 | - |

---

## API 使用

### 基础端点

- **API 基础路径**: `/api/v1`
- **健康检查**: `GET /api/v1/health`
- **API 文档**: `GET /api/v1/swagger.yaml`

### 主要 API

#### 创建标志

```bash
curl -X POST http://localhost:18000/api/v1/flags \
  -H "Content-Type: application/json" \
  -d '{
    "description": "我的第一个功能标志",
    "key": "my-first-flag",
    "enabled": true
  }'
```

#### 获取所有标志

```bash
curl http://localhost:18000/api/v1/flags
```

#### 评估标志

```bash
curl -X POST http://localhost:18000/api/v1/evaluation \
  -H "Content-Type: application/json" \
  -d '{
    "entityID": "user-123",
    "entityType": "user",
    "entityContext": {
      "age": 25,
      "country": "CN"
    },
    "flagID": 1,
    "enableDebug": true
  }'
```

#### 批量评估

```bash
curl -X POST http://localhost:18000/api/v1/evaluation/batch \
  -H "Content-Type: application/json" \
  -d '{
    "entities": [
      {"entityID": "user-1", "entityType": "user"},
      {"entityID": "user-2", "entityType": "user"}
    ],
    "flagIDs": [1, 2, 3],
    "enableDebug": false
  }'
```

#### 创建变体

```bash
curl -X POST http://localhost:18000/api/v1/flags/1/variants \
  -H "Content-Type: application/json" \
  -d '{
    "key": "variant-a",
    "attachment": {"color": "blue"}
  }'
```

#### 创建分段

```bash
curl -X POST http://localhost:18000/api/v1/flags/1/segments \
  -H "Content-Type: application/json" \
  -d '{
    "description": "中国用户",
    "rolloutPercent": 100,
    "constraints": [
      {
        "property": "country",
        "operator": "EQ",
        "value": "CN"
      }
    ]
  }'
```

### 支持的操作符

| 操作符 | 说明 | 示例 |
|--------|------|------|
| `EQ` | 等于 | `country EQ CN` |
| `NEQ` | 不等于 | `country NEQ US` |
| `GT` | 大于 | `age GT 18` |
| `GTE` | 大于等于 | `age GTE 18` |
| `LT` | 小于 | `age LT 65` |
| `LTE` | 小于等于 | `age LTE 65` |
| `IN` | 包含于 | `country IN US,CN,UK` |
| `NOTIN` | 不包含于 | `country NOTIN US` |
| `CONTAINS` | 字符串包含 | `name CONTAINS admin` |
| `STARTSWITH` | 字符串开头 | `name STARTSWITH user_` |
| `ENDSWITH` | 字符串结尾 | `email ENDSWITH @gmail.com` |
| `REGEX` | 正则匹配 | `email REGEX ^.*@gmail\\.com$` |

---

## 前端界面

### 访问界面

服务启动后，访问 http://localhost:18000 即可进入管理界面。

### 主要功能

1. **标志管理**
   - 创建、编辑、删除标志
   - 启用/禁用标志
   - 设置标志描述和标签

2. **变体管理**
   - 添加多个变体
   - 设置变体附件（JSON 格式）

3. **分段管理**
   - 创建用户分段
   - 设置约束条件
   - 配置发布百分比

4. **分布配置**
   - 设置各变体的分配比例
   - 可视化查看分布情况

5. **调试控制台**
   - 实时测试标志评估
   - 查看评估结果和调试信息

### 语言切换

在导航栏右侧点击 "Language" 下拉菜单，支持：
- English（英语）
- 中文（简体中文）

---

## 数据库配置

### SQLite（开发推荐）

```bash
# 文件数据库
export FLAGR_DB_DBDRIVER=sqlite3
export FLAGR_DB_DBCONNECTIONSTR=/path/to/flagr.db

# 内存数据库（仅用于测试）
export FLAGR_DB_DBCONNECTIONSTR=":memory:"
```

### MySQL

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE flagr CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 配置连接
export FLAGR_DB_DBDRIVER=mysql
export FLAGR_DB_DBCONNECTIONSTR="user:password@tcp(127.0.0.1:3306)/flagr?parseTime=true"
```

### PostgreSQL

```bash
# 创建数据库
psql -U postgres -c "CREATE DATABASE flagr;"

# 配置连接
export FLAGR_DB_DBDRIVER=postgres
export FLAGR_DB_DBCONNECTIONSTR="postgres://user:password@localhost:5432/flagr?sslmode=disable"
```

---

## 生产部署

### Docker Compose 示例

```yaml
version: '3.8'

services:
  flagr:
    image: ghcr.io/openflagr/flagr:latest
    ports:
      - "18000:18000"
    environment:
      - HOST=0.0.0.0
      - PORT=18000
      - FLAGR_DB_DBDRIVER=postgres
      - FLAGR_DB_DBCONNECTIONSTR=postgres://flagr:password@postgres:5432/flagr?sslmode=disable
      - FLAGR_CORS_ENABLED=true
      - FLAGR_PROMETHEUS_ENABLED=true
    depends_on:
      - postgres
    volumes:
      - flagr_data:/data

  postgres:
    image: postgres:14
    environment:
      - POSTGRES_USER=flagr
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=flagr
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  flagr_data:
  postgres_data:
```

### Kubernetes 部署示例

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flagr
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flagr
  template:
    metadata:
      labels:
        app: flagr
    spec:
      containers:
      - name: flagr
        image: ghcr.io/openflagr/flagr:latest
        ports:
        - containerPort: 18000
        env:
        - name: HOST
          value: "0.0.0.0"
        - name: PORT
          value: "18000"
        - name: FLAGR_DB_DBDRIVER
          value: "postgres"
        - name: FLAGR_DB_DBCONNECTIONSTR
          valueFrom:
            secretKeyRef:
              name: flagr-secret
              key: db-connection
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: flagr
spec:
  selector:
    app: flagr
  ports:
  - port: 80
    targetPort: 18000
  type: LoadBalancer
```

### 性能优化建议

1. **数据库优化**
   - 使用连接池
   - 添加适当的索引
   - 定期清理历史快照

2. **缓存配置**
   - 调整 `FLAGR_EVALCACHE_REFRESHINTERVAL`
   - 调整 `FLAGR_EVALCACHE_REFRESHTIMEOUT`

3. **监控配置**
   - 启用 Prometheus 指标
   - 配置健康检查

---

## 常见问题

### 1. 服务无法启动

**问题**: 端口被占用

**解决方案**:
```bash
# 检查端口占用
lsof -i :18000

# 使用其他端口
./flagr --port 18001
```

### 2. 数据库连接失败

**问题**: 数据库连接配置错误

**解决方案**:
```bash
# 检查数据库连接
# MySQL
mysql -u root -p -h 127.0.0.1 -e "SELECT 1"

# PostgreSQL
psql -U postgres -h localhost -c "SELECT 1"

# 启用数据库调试
export FLAGR_DB_DBCONNECTION_DEBUG=true
```

### 3. 前端无法访问

**问题**: 前端未构建或路径错误

**解决方案**:
```bash
# 构建前端
cd browser/flagr-ui
npm install
npm run build
```

### 4. CORS 错误

**问题**: 跨域请求被阻止

**解决方案**:
```bash
# 启用 CORS
export FLAGR_CORS_ENABLED=true
export FLAGR_CORS_ALLOWED_ORIGINS="http://localhost:3000,http://example.com"
```

### 5. 评估结果不符合预期

**问题**: 分段配置或约束条件有误

**解决方案**:
1. 使用调试控制台测试
2. 在评估请求中设置 `enableDebug: true`
3. 检查约束条件的操作符和值

---

## 更多资源

- **官方文档**: https://openflagr.github.io/flagr
- **API 文档**: https://openflagr.github.io/flagr/api_docs
- **GitHub**: https://github.com/openflagr/flagr
- **问题反馈**: https://github.com/openflagr/flagr/issues