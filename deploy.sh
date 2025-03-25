#!/bin/bash

# Railsのルートディレクトリに移動
cd "$(dirname "$0")"

# サーバーが動いているか確認し、動いていれば停止
if [ -f tmp/pids/server.pid ]; then
    echo "Stopping Rails server..."
    kill -9 $(cat tmp/pids/server.pid)
    rm tmp/pids/server.pid
else
    echo "No running Rails server found"
fi

# 最新のコードを取得
echo "Pulling latest code..."
git pull origin main

# アセットのプリコンパイル
echo "Precompiling assets..."
RAILS_ENV=production bundle exec rails assets:precompile

# サーバーを起動
echo "Starting Rails server..."
bundle exec rails s -p 3005 -d

echo "Deploy completed!"