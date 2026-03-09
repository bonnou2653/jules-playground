# Pure Synth Backend

PureScriptで実装されたバックエンドプロジェクトです。

## デプロイ方法 (Cloudflare Workers)

本プロジェクトは、無料枠が強力でPureScriptとの相性も良い **Cloudflare Workers** へのデプロイを想定しています。

### 1. 概要
- **プラットフォーム**: Cloudflare Workers
- **理由**: 1日10万リクエストまで無料（Freeプラン）、エッジ実行による低遅延、JSへのコンパイル後のデプロイが容易。
- **仕組み**: `spago bundle` で1つのJavaScriptファイルにまとめ、`wrangler` CLIを使用してデプロイします。

### 2. 役割分担
デプロイと運用における、ユーザーとエージェント（Jules）の役割は以下の通りです。

| 項目 | ユーザーの役割 | Julesの役割 |
| :--- | :--- | :--- |
| **アカウント準備** | Cloudflareアカウントの作成 | (不可) |
| **環境設定** | APIトークンの取得、GitHub Secretsへの設定 | READMEの保守 |
| **ビルド** | (任意) | `spago bundle` によるJS生成 |
| **デプロイ(手動)** | 承認、またはJulesへの指示 | `wrangler deploy` の実行 |
| **デプロイ(自動)** | 本番環境が必要になった際のCI設定 | CI/CD YAMLの作成・修正 |
| **動作確認** | ブラウザでの最終確認 | `curl` や `wrangler tail` による検証 |

### 3. デプロイ準備
事前に以下の準備が必要です。
1. [Cloudflare アカウント](https://dash.cloudflare.com/sign-up)の作成。
2. `wrangler` のインストール（初回のみ）:
   ```bash
   npm install -g wrangler
   ```
3. Cloudflareへのログイン、またはAPIトークンの発行。
   - Julesがデプロイを行う場合は、`CLOUDFLARE_API_TOKEN` 環境変数が必要です。

### 4. 手動デプロイ手順
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
   # APIトークンが設定されている場合
   export CLOUDFLARE_API_TOKEN=your_token_here
   npx wrangler deploy dist/index.js --name pure-synth-backend
   ```

### 5. 自動デプロイ (CI/CD) ※将来用
`main` ブランチにマージされた際に自動でデプロイされるように、GitHub Actionsを設定する際の構成案です。本番環境が必要になったタイミングで導入を検討します。

**`.github/workflows/deploy.yml` の例:**
(省略可ですが、参考として前述のYAMLを残しておきます)

### 6. エージェント（Jules）による動作確認方針
Julesが単独で動作確認を行う際は、以下の手順を実施します。

1. **ローカル検証**:
   - `npm run test` による単体テストの実行。
   - `npx wrangler dev` (ローカルプレビュー) をバックグラウンドで起動し、`curl` でエンドポイントを叩いて期待通りのレスポンスが返るか確認。
2. **デプロイ後検証**:
   - `curl -v https://pure-synth-backend.<your-subdomain>.workers.dev` を実行し、ステータスコード 200 および期待されるボディを確認。
   - `npx wrangler tail pure-synth-backend` を一時的に実行して、エラーログが出ていないか確認。
