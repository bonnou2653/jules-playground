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
| **環境設定** | APIトークンの取得、Julesへの共有 | READMEの保守 |
| **ビルド** | (任意) | `spago bundle` によるJS生成 |
| **デプロイ(手動)** | 承認、またはJulesへの指示 | `wrangler deploy` の実行 |
| **デプロイ(自動)** | 本番環境が必要になった際のCI設定 | CI/CD YAMLの作成・修正 |
| **動作確認** | ブラウザでの最終確認 | `curl` や `wrangler tail` による検証 |

#### シークレット情報の管理について
デプロイに必要な `CLOUDFLARE_API_TOKEN` などのシークレット情報は、リポジトリに保存できません。以下の手順でJulesに共有してください。
- **Julesへの共有方法**: Julesとのチャット内で「以下の環境変数を設定してデプロイしてください」と伝え、トークンを直接入力してください。Julesはそのセッション内で環境変数として保持し、デプロイを実行します。
- **非公開ではない設定**: サービス名や公開可能な設定値については、`apps/pure-synth/pure-synth-backend/wrangler.toml` に直接記述して管理することを推奨します。

### 3. デプロイ準備
事前に以下の準備が必要です。
1. [Cloudflare アカウント](https://dash.cloudflare.com/sign-up)の作成。
2. `wrangler` のインストール（初回のみ）:
   ```bash
   npm install -g wrangler
   ```
3. Cloudflareへのログイン、またはAPIトークンの発行。

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
   # APIトークンが共有されている場合、Julesは以下のように実行します
   export CLOUDFLARE_API_TOKEN=shared_token_here
   npx wrangler deploy dist/index.js --name pure-synth-backend
   ```

### 5. 自動デプロイ (CI/CD) ※将来用
`main` ブランチにマージされた際に自動でデプロイされるように、GitHub Actionsを設定する際の構成案です。本番環境が必要になったタイミングで導入を検討します。

### 6. エージェント（Jules）による動作確認方針
Julesが単独で動作確認を行う際は、以下の手順を実施します。

1. **ローカル検証**:
   - `npm run test` による単体テストの実行。
   - `npx wrangler dev` (ローカルプレビュー) をバックグラウンドで起動し、`curl` でエンドポイントを叩いて期待通りのレスポンスが返るか確認。
2. **デプロイ後検証**:
   - `curl -v https://pure-synth-backend.<your-subdomain>.workers.dev` を実行し、ステータスコード 200 および期待されるボディを確認。
   - `npx wrangler tail pure-synth-backend` を一時的に実行して、エラーログが出ていないか確認。
