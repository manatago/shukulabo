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
git pull origin main || { echo "Failed to pull code"; exit 1; }

# Bundlerの実行
echo "Installing dependencies..."
bundle install || { echo "Failed to install dependencies"; exit 1; }

# データベースマイグレーション
echo "Running database migrations..."
bundle exec rails db:migrate || { echo "Failed to run migrations"; exit 1; }

# アセットのプリコンパイル
echo "Precompiling assets..."
bundle exec rails assets:precompile || { echo "Failed to precompile assets"; exit 1; }

# サーバーを起動
echo "Starting Rails server..."
bundle exec rails s -p 3005 -d || { echo "Failed to start server"; exit 1; }

echo "Deploy completed successfully!"