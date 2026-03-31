<p align="center">
    <a href="https://github.com/openflagr/flagr/actions/workflows/ci.yml?query=branch%3Amain+" target="_blank">
        <img src="https://github.com/openflagr/flagr/actions/workflows/ci.yml/badge.svg?branch=main">
    </a>
    <a href="https://goreportcard.com/report/github.com/openflagr/flagr" target="_blank">
        <img src="https://goreportcard.com/badge/github.com/openflagr/flagr">
    </a>
    <a href="https://godoc.org/github.com/openflagr/flagr" target="_blank">
        <img src="https://img.shields.io/badge/godoc-reference-green.svg">
    </a>
    <a href="https://github.com/openflagr/flagr/releases" target="_blank">
        <img src="https://img.shields.io/github/release/openflagr/flagr.svg?style=flat&color=green">
    </a>
    <a href="https://codecov.io/gh/openflagr/flagr">
        <img src="https://codecov.io/gh/openflagr/flagr/branch/main/graph/badge.svg?token=iwjv26grrN">
    </a>
    <a href="https://deepwiki.com/openflagr/flagr">
        <img src="https://deepwiki.com/badge.svg?color=green" alt="Ask DeepWiki">
    </a>
</p>

## 简介

`openflagr/flagr` 是一个社区驱动的开源项目，致力于推进 Flagr 的开发。

Flagr 是一个开源的 Go 语言服务，用于向正确的实体提供正确的体验并监控其影响。它提供功能标志、实验（A/B 测试）和动态配置功能。它拥有清晰的 Swagger REST API，用于标志管理和标志评估。

## 特性

- **功能标志**：轻松开启/关闭功能
- **A/B 测试**：进行实验以比较不同变体
- **动态配置**：运行时动态修改配置
- **RESTful API**：清晰的 Swagger API 文档
- **高性能**：每秒可处理 2000+ 请求
- **Web UI**：直观的图形化管理界面
- **多语言客户端**：支持 Go、JavaScript、Python、Ruby 等

## 文档

- 官方文档：https://openflagr.github.io/flagr
- API 文档：https://openflagr.github.io/flagr/api_docs

## 快速开始

### 使用 Docker

```sh
# 拉取 Docker 镜像
docker pull ghcr.io/openflagr/flagr

# 启动容器
docker run -it -p 18000:18000 ghcr.io/openflagr/flagr

# 打开 Flagr UI
open localhost:18000
```

### 在线演示

访问 [https://try-flagr.onrender.com](https://try-flagr.onrender.com) 在线体验。

注意：冷启动可能需要一些时间，每次提交到 `main` 分支都会触发演示网站的重新部署。

### API 示例

```bash
curl --request POST \
     --url https://try-flagr.onrender.com/api/v1/evaluation \
     --header 'content-type: application/json' \
     --data '{
       "entityID": "127",
       "entityType": "user",
       "entityContext": {
         "state": "NY"
       },
       "flagID": 1,
       "enableDebug": true
     }'
```

## 性能指标

使用 `vegeta` 进行性能测试，详细结果请参考 [benchmarks](./benchmark)。

```
请求数        [总计, 速率]            56521, 2000.04
持续时间      [总计, 攻击, 等待]       28.2603654s, 28.259999871s, 365.529µs
延迟          [平均, 50%, 95%, 99%, 最大]  371.632µs, 327.991µs, 614.918µs, 1.385568ms, 12.50012ms
接收字节      [总计, 平均]            23250552, 411.36
发送字节      [总计, 平均]            8308587, 147.00
成功率        [比例]                  100.00%
状态码        [代码:数量]             200:56521
错误集:
```

## Flagr UI 界面

<p align="center">
    <img src="./docs/images/demo_readme.png" width="900">
</p>

## 国际化支持

Flagr UI 支持多语言界面：

- **English** - 英语（默认）
- **中文** - 简体中文

语言切换：在页面顶部导航栏点击"Language"下拉菜单即可切换语言。语言设置会保存在浏览器本地存储中。

## 客户端库

| 语言       | 客户端库                                         |
| ---------- | ----------------------------------------------- |
| Go         | [goflagr](https://github.com/openflagr/goflagr) |
| JavaScript | [jsflagr](https://github.com/openflagr/jsflagr) |
| Python     | [pyflagr](https://github.com/openflagr/pyflagr) |
| Ruby       | [rbflagr](https://github.com/openflagr/rbflagr) |

## 开发

### 前端开发

```sh
cd browser/flagr-ui

# 安装依赖
npm install

# 开发模式运行
npm run serve

# 构建生产版本
npm run build
```

### 添加新语言翻译

1. 在 `browser/flagr-ui/src/locales/` 目录下创建新的语言 JSON 文件
2. 在 `browser/flagr-ui/src/locales/index.js` 中导入并注册新语言
3. 在 `browser/flagr-ui/src/App.vue` 的语言下拉菜单中添加选项

## 许可证与致谢

- [`openflagr/flagr`](https://github.com/openflagr/flagr) Apache 2.0
- [`checkr/flagr`](https://github.com/checkr/flagr) Apache 2.0