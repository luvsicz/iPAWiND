FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install essential packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    nodejs \
    npm \
    zip \
    unzip \
    build-essential \
    checkinstall \
    zlib1g-dev \
    libssl-dev \
    git \
    make \
    g++ \
    pkg-config \
    libminizip-dev \
    zlib1g-dev \
    curl \
    tzdata \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configure timezone
RUN ln -fs /usr/share/zoneinfo/Etc/UTC /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Set working directory
WORKDIR /app

# Copy project files
COPY . .

# Install Node.js dependencies
RUN npm install node-forge ocsp && nodejs tools/checker/resources.js

# Install Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt PyJWT pytz tzlocal

# Environment variables for configuration
# Bot configuration
ENV BOT_TOKEN="Your Bot Token" \
    API_ID="8" \
    API_HASH="72422335de8e747a0d6fbe11f7cc14fcc0bb" \
    SERVER_ADDRESS="Your-url-shortner-api" \
    ADMIN_IDS="123123123" \
    PASSWORD="1" \
    API_KEY="" \
    # R2 Storage configuration
    R2_ENDPOINT="https://Example.r2.cloudflarestorage.com" \
    R2_ACCESS_KEY="KeyExample" \
    R2_SECRET_KEY="LongKeyExaemplef74b9f9b30bbaa7ad72eb053c9f7616" \
    R2_BUCKET_NAME="BucketName" \
    R2_DOMAIN="https://yourDomainforR2.com" \
    # R2 PLIST Storage configuration
    R2_PLIST_ENDPOINT="https://Example.r2.cloudflarestorage.com" \
    R2_PLIST_ACCESS_KEY="KeyExample" \
    R2_PLIST_SECRET_KEY="LongKeyExaemplef74b9f9b30bbaa7ad72eb053c9f7616" \
    R2_PLIST_BUCKET_NAME="Bucketname" \
    R2_PLIST_DOMAIN="https://yourDomainforR2.com"

# Create a script to update configuration from environment variables
COPY <<'EOF' /app/entrypoint.sh
#!/bin/bash

# Update config.py with environment variables
cat > bot/config.py << EOL
api_id = ${API_ID}  # get this from my.telegram.org
api_hash = "${API_HASH}" # get this from my.telegram.org
bot_token = "${BOT_TOKEN}"  # get it from @botfather
server_address = "${SERVER_ADDRESS}" # your url shortner api

PASSWORD = "${PASSWORD}"
api_key = "${API_KEY}"
api_urls = []

admin = [${ADMIN_IDS}] # add your telegram user ID
reseller = []

web_path = "/var/www/html"
template = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>items</key>
    <array>
      <dict>
        <key>assets</key>
        <array>
          <dict>
            <key>kind</key>
            <string>software-package</string>
            <key>url</key>
            <string><![CDATA[{url}]]></string>
          </dict>
          <dict>
            <key>kind</key>
            <string>full-size-image</string>
            <key>url</key>
            <string><![CDATA[{redirect_url}]]></string>
          </dict>
          <dict>
            <key>kind</key>
            <string>display-image</string>
            <key>url</key>
            <string><![CDATA[{redirect_url}]]></string>
          </dict>
        </array>
        <key>metadata</key>
        <dict>
          <key>bundle-identifier</key>
          <string><![CDATA[{package_name}]]></string>
          <key>bundle-version</key>
          <string>1.0.0</string>
          <key>kind</key>
          <string>software</string>
          <key>title</key>
          <string>{appname}</string>
        </dict>
      </dict>
    </array>
  </dict>
</plist>"""


accounts = [
]

reseller_accounts = {
}


excluded_accounts = (

)
EOL

# Update loader.py with R2 configuration
cat > bot/loader.py << EOL
import sqlite3

from aiogram import Bot, Dispatcher
from aiogram.bot.api import TelegramAPIServer
from aiogram.contrib.fsm_storage.memory import MemoryStorage

from bot.config import bot_token, accounts, reseller_accounts, api_id, api_hash
from bot.utils.r2 import R2Storage
from pyrogram import Client 

server = TelegramAPIServer.from_base("http://api:8081")
# server = TelegramAPIServer.from_base("http://nginx:81")
bot = Bot(bot_token, server=server)
pyrogram_bot = Client(name="pyrobot", api_id=api_id, api_hash=api_hash, bot_token=bot_token, no_updates=True, max_concurrent_transmissions=20)
pyrogram_bot.start()

dp = Dispatcher(bot, storage=MemoryStorage())

conn = sqlite3.connect("database.db")
cursor = conn.cursor()

r2 = R2Storage('${R2_ENDPOINT}',
               '${R2_ACCESS_KEY}',
               '${R2_SECRET_KEY}',
               '${R2_BUCKET_NAME}', '${R2_DOMAIN}')


r2_plist = R2Storage('${R2_PLIST_ENDPOINT}',
                     '${R2_PLIST_ACCESS_KEY}',
                     '${R2_PLIST_SECRET_KEY}',
                     '${R2_PLIST_BUCKET_NAME}', '${R2_PLIST_DOMAIN}')


from bot.utils.account_manager import AccountManager, ChineseApi

account_manager = AccountManager.from_list(accounts, reseller_accounts)
chinese_api = ChineseApi()
EOL

# Update __main__.py to use a specific timezone for APScheduler and fix asyncio event loop
cat > bot/__main__.py << EOL
import logging
from logging.handlers import RotatingFileHandler
import asyncio

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from aiogram import executor
import pytz

from bot import handlers
from bot.loader import dp, account_manager, r2
from datetime import datetime, timedelta 

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s.%(msecs)03d %(levelname)s %(module)s - %(funcName)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S', 
    handlers=[
        logging.StreamHandler(),
        RotatingFileHandler('bot.log', mode="w", maxBytes=10*5*1024, backupCount=1),
    ]
)

logging.getLogger("pyrogram").setLevel(logging.WARNING)

async def on_startup(dp):
    # Use Asia/Shanghai timezone for scheduler to avoid timezone issues
    scheduler = AsyncIOScheduler(timezone=pytz.timezone('Asia/Shanghai'))
    
    scheduler.add_job(account_manager.update_udids_data, 'interval', minutes=30)
    # scheduler.add_job(account_manager.update_udids_data, 'interval', minutes=180, next_run_time=datetime.now())

    scheduler.start()

if __name__ == "__main__":
    executor.start_polling(dp, on_startup=on_startup)
EOL

# Start the bot
python3 -m bot
EOF

RUN chmod +x /app/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]
