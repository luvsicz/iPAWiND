# Telegram iOS应用签名机器人

iPAWiND是一个用于Telegram的iOS应用签名机器人。它允许用户通过Telegram直接签名并安装iOS应用程序，使旁加载过程更加便捷。

Telegram机器人: [@ipawind_bot](https://t.me/ipawind_bot)

## 功能特点

- 通过Telegram直接签名iOS应用（.ipa文件）
- 自动配置文件管理
- 支持各种签名证书
- 简易安装和配置
- 支持Docker部署

## 前提条件

- Linux服务器（推荐Ubuntu/Debian）
- Python 3.8+
- Node.js和npm
- Docker和Docker Compose（可选，用于容器化部署）
- Telegram Bot API令牌

## 安装

## 步骤1：设置Cloudflare Worker短链接服务

使用Cloudflare Workers设置URL短链接服务：
- 按照以下指南操作：https://github.com/AppleEcosystem/ShortFlare
- 更新`SERVER_ADDRESS`环境变量（Docker）

## 步骤2：配置Cloudflare R2

1. 在您的Cloudflare账户中创建R2存储桶
2. 配置R2设置：
   - 对于Docker：在`.env`文件中更新R2环境变量

## 步骤3：Docker Compose运行

1. 安装Docker和Docker Compose：
   - 按照Docker安装指南操作：https://docs.docker.com/engine/install/ubuntu/
   - 按照Docker Compose安装指南操作：https://docs.docker.com/compose/install/

2. 配置环境变量：
   ```bash
   cp .env.example .env
   ```
   使用您的配置编辑`.env`文件：
   - 设置您的Telegram Bot令牌（`BOT_TOKEN`）
   - 配置Cloudflare R2设置

3. 构建并启动容器：
   ```bash
   docker compose down && docker compose build && docker compose up -d
   ```
4. 编译不同架构平台能使用的zsign （可选）
 - 按照 https://github.com/zhlynn/zsign 教程编译替换即可

这将启动两个服务：
- `api`：Telegram Bot API服务器
- `ipawind`：iPAWiND机器人服务

### 环境变量

所有配置通过环境变量完成：

| 变量 | 描述 | 默认值 |
|----------|-------------|---------|
| BOT_TOKEN | 您的Telegram Bot令牌 | - |
| API_ID | Telegram API ID | 8888888 |
| API_HASH | Telegram API Hash | aaabbbcccdddeeefffffff |
| SERVER_ADDRESS | URL短链接API地址 | - |
| ADMIN_IDS | 管理员用户ID（逗号分隔列表） | 8888888 |
| R2_ENDPOINT | Cloudflare R2端点 | - |
| R2_ACCESS_KEY | Cloudflare R2访问密钥 | - |
| R2_SECRET_KEY | Cloudflare R2密钥 | - |
| R2_BUCKET_NAME | Cloudflare R2存储桶名称 | - |
| R2_DOMAIN | Cloudflare R2域名 | - |

有关环境变量的完整列表，请参阅`.env.example`文件。

# 设置完成

在TG上发起会话即可
