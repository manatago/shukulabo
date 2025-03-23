# 宿題管理システム

家庭教師が生徒の宿題を管理するためのシステムです。

## 機能

- Google認証によるログイン
- 管理者ユーザーによるシステム管理
- 生徒のグループ管理
- 教材の登録（画像・テキスト）
- 教材へのタグ付け

## セットアップ

### 必要要件

- Ruby 3.2.0以上
- MySQL 8.0以上
- Node.js 18.0.0以上
- Yarn 1.22.0以上

### インストール手順

1. リポジトリのクローン
```bash
git clone [repository-url]
cd [repository-name]
```

2. 依存関係のインストール
```bash
bundle install
yarn install
```

3. データベースの作成と初期化
```bash
rails db:create
rails db:migrate
```

### Google OAuth2の設定

1. [Google Cloud Console](https://console.cloud.google.com/)にアクセス
2. 新しいプロジェクトを作成
   - 画面右上のプロジェクト選択 → 「新しいプロジェクト」
   - プロジェクト名を入力して作成

3. OAuth同意画面の設定
   - 左メニューから「APIとサービス」→「OAuth同意画面」
   - ユーザータイプ: 外部を選択
   - アプリ名: "Shukulabo"
   - ユーザーサポートメール: 自分のメールアドレス
   - デベロッパーの連絡先情報: 自分のメールアドレス
   - 承認済みドメイン: アプリケーションのドメインを追加

4. 認証情報の作成
   - 左メニューから「APIとサービス」→「認証情報」
   - 「認証情報を作成」→「OAuth クライアントID」を選択
   - アプリケーションの種類: ウェブアプリケーション
   - 名前: "Shukulabo Web Client"
   - 承認済みのリダイレクトURI:
     - 開発環境:
       * `http://localhost:3000/auth/google_oauth2/callback`
       * `http://localhost:3005/auth/google_oauth2/callback`
       * `http://127.0.0.1:3000/auth/google_oauth2/callback`
       * `http://127.0.0.1:3005/auth/google_oauth2/callback`
     - 本番環境: `https://[your-domain]/auth/google_oauth2/callback`

5. 認証情報の取得と設定
   - クライアントIDとクライアントシークレットをメモ
   - .envファイルを作成（.env.sampleをコピー）して以下を設定：
   ```
   GOOGLE_CLIENT_ID=your_client_id
   GOOGLE_CLIENT_SECRET=your_client_secret
   ```

注意: ポート番号を変更して起動する場合は、必ずGoogle Cloud Consoleの承認済みリダイレクトURIにそのポート番号のURIを追加してください。

### 環境変数の設定

.env.sampleファイルを.envにコピーし、必要な情報を設定してください：

```
GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
```

### アプリケーションの起動

```bash
bin/dev
```

アプリケーションは http://localhost:3000 で起動します。

## 初期設定

- 最初にログインしたユーザーが自動的に管理者ユーザーとして設定されます
- 管理者ユーザーは他のユーザーに管理者権限を付与できます
