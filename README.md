# Telegram iOS app signer bot.

iPAWiND is an iOS app signer bot for Telegram. It allows users to sign and install iOS applications directly through Telegram, making the sideloading process more accessible.

Telegram Bot: [@ipawind_bot](https://t.me/ipawind_bot)

## Features

- Sign iOS apps (.ipa files) directly through Telegram
- Automatic provisioning profile management
- Support for various signing certificates
- Easy installation and configuration
- Docker support for simple deployment

## Prerequisites

- Linux server (Ubuntu/Debian recommended)
- Python 3.8+
- Node.js and npm
- Docker and Docker Compose (optional, for containerized setup)
- Telegram Bot API token

## Installation

## Step 1: Setup Cloudflare Worker Shortener

Set up a URL shortener using Cloudflare Workers:
- Follow the guide at: https://github.com/AppleEcosystem/ShortFlare
- Update the `SERVER_ADDRESS` environment variable (Docker)

## Step 2: Configure Cloudflare R2

1. Create an R2 bucket in your Cloudflare account
2. Configure R2 settings:
   - For Docker: Update the R2 environment variables in your `.env` file

## Step 3: Docker Compose Run (X86_64 ARCH Only)

1. Install Docker and Docker Compose:
   - Follow the Docker installation guide: https://docs.docker.com/engine/install/ubuntu/
   - Follow the Docker Compose installation guide: https://docs.docker.com/compose/install/

2. Configure environment variables:
   ```bash
   cp .env.example .env
   ```
   Edit the `.env` file with your configuration:
   - Set your Telegram Bot token (`BOT_TOKEN`)
   - Configure Cloudflare R2 settings

3. Build and start the containers:
   ```bash
   docker compose down && docker compose build && docker compose up -d
   ```

This will start two services:
- `api`: Telegram Bot API server
- `ipawind`: The iPAWiND bot service

### Environment Variables

All configuration is done through environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| BOT_TOKEN | Your Telegram Bot token | - |
| API_ID | Telegram API ID | 8 |
| API_HASH | Telegram API Hash | 7245de8e747a0d6fbe11f7cc14fcc0bb |
| SERVER_ADDRESS | URL shortener API address | - |
| ADMIN_IDS | Comma-separated list of admin user IDs | 719363292 |
| R2_ENDPOINT | Cloudflare R2 endpoint | - |
| R2_ACCESS_KEY | Cloudflare R2 access key | - |
| R2_SECRET_KEY | Cloudflare R2 secret key | - |
| R2_BUCKET_NAME | Cloudflare R2 bucket name | - |
| R2_DOMAIN | Cloudflare R2 domain | - |

For a complete list of environment variables, see the `.env.example` file.

# Setup Complete

Your iPAWiND setup is now ready. If you encounter any issues, double-check the configuration files and ensure all packages are properly installed, or create an issue on GitHub.


