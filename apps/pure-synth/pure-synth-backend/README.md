# Pure Synth Backend

PureScriptで実装されたバックエンドプロジェクトです。

## デプロイ方法 (Cloudflare Workers)

本プロジェクトは、無料枠が強力でPureScriptとの相性も良い **Cloudflare Workers** へのデプロイを想定しています。

### 1. 概要
- **プラットフォーム**: Cloudflare Workers
- **理由**: 1日10万リクエストまで無料（Freeプラン）、エッジ実行による低遅延、JSへのコンパイル後のデプロイが容易。
- **仕組み**: `spago bundle` で1つのJavaScriptファイルにまとめ、`wrangler` CLIを使用してデプロイします。

### 2. デプロイ準備
事前に以下の準備が必要です。
1. [Cloudflare アカウント](https://dash.cloudflare.com/sign-up)の作成。
2. `wrangler` のインストール（初回のみ）:
   ```bash
   npm install -g wrangler
   ```
3. Cloudflareへのログイン:
   ```bash
   npx wrangler login
   ```

### 3. 手動デプロイ手順
以下のコマンドを実行することで、開発環境から直接デプロイできます。

1. **ビルドとバンドル**:
   PureScriptのコードをCloudflare Workersで実行可能な1つのJavaScriptファイルにまとめます。
   ```bash
   npx spago bundle --module Main --outfile dist/index.js --platform node
   ```
   *(注: 実際のWorker実装では、Cloudflare Workersのハンドラ形式に合わせるためのラッパーが必要になる場合があります)*

2. **デプロイ**:
   `wrangler` を使用してデプロイします。
   ```bash
   npx wrangler deploy dist/index.js --name pure-synth-backend
   ```

### 4. 自動デプロイ (CI/CD)
`main` ブランチにマージされた際に自動でデプロイされるように、GitHub Actionsを設定することを推奨します。

**`.github/workflows/deploy.yml` の例:**
```yaml
name: Deploy Backend

on:
  push:
    branches:
      - main
    paths:
      - 'apps/pure-synth/pure-synth-backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Dependencies
        run: |
          npm ci

      - name: Build and Bundle
        run: |
          cd apps/pure-synth/pure-synth-backend
          npx spago bundle --module Main --outfile dist/index.js --platform node

      - name: Deploy to Cloudflare Workers
        uses: cloudflare/wrangler-action@v3
        with:
          apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
          workingDirectory: 'apps/pure-synth/pure-synth-backend'
          command: deploy dist/index.js --name pure-synth-backend
```

### 5. 動作確認
デプロイ後、以下の方法で動作を確認できます。

1. **URLへのアクセス**:
   デプロイ完了時に表示される `https://pure-synth-backend.<your-subdomain>.workers.dev` にアクセスします。
2. **ログの確認**:
   リアルタイムでログを確認するには以下のコマンドを使用します。
   ```bash
   npx wrangler tail pure-synth-backend
   ```
