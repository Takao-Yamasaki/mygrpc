# gRPC-sample
## gRPCurl
- curlのようにターミナル上でgRPCのリクエストを送信できる
- セットアップで、`grpcurl`のdockerイメージを取得している

## コンテナの起動
```
make up
```
## サーバーの起動
```
make server
```
## サービス一覧の確認
```
make service
```
## メソッドの一覧の確認
```
make method
```
## メソッドの呼び出し
```
make callmethod
```

## デプロイ手順
### IAMユーザーの作成
- IAMユーザーを作成しておくこと
- AWS CLIを使用するので、IAM作成後、次のコマンドで認証設定をしておくこと
- https://avinton.com/academy/aws-cli-install-setting/
```
aws configure
```

### ECRのレポジトリを作成
AWS CLIを使用して、レポジトリを作成
- ECRを作成
```
aws ecr create-repository --repository-name myecs
```
- ECRが作成されたかどうか確認。プライベートリポジトリに作成される。
```
aws ecr describe-repositories --repository-name myecs
```

### イメージをECRにプッシュ
AWS CLIを使用して、ECRにイメージプッシュ
- マネージメントコンソールを開き、[Amazon ECR][リポジトリ][mygrpc][プッシュコマンドの表示]を押下し、表示されるコマンドをAWS CLIで実行していく
- 1.認証トークンを取得し、レジストリに対して Dockerクライアントを認証。
- 2.以下のコマンドを使用して、Dockerイメージを構築
```
make build-prod
```
- 3.構築が完了したら、このリポジトリにイメージをプッシュできるように、イメージにタグを付け
- 4.新しく作成した AWS リポジトリにこのイメージをプッシュ
- https://dev.classmethod.jp/articles/beginner-series-to-check-how-t-create-docker-image-and-push-to-amazon-ecr/

### Route53でドメインを取得
- マネージメントコンソールを使って、Route53でドメインを登録しておく
### ACMでHTTPS化
- マネージメントコンソールを使って、ACMでSSL証明書を発行しておく
### Terraformのインストール
- Terraformのバージョン管理にtfenvを使用しているので、事前にインストールする
```
brew install tfenv
```
- .terraform-versionで記載していいるバージョンのTerraformをインストール
```
tfenv install
```
### AWSへのデプロイ
- `network/prd`配下:  VPCなどネットワーク関連のリソースを管理
- `ecs/prd`配下:  ECSなどのサーバー関連のリソースを管理
1. `network/prd`ディレクトリに移動
```
cd network/prd
```
2. 実行計画を出力
```
terraform plan
```
3. 実行計画を表示し、[yes]を入力すると、AWSリソースが作成される
```
terraform apply
```
4. `ecs/prd`でも上の手順を繰り返す
## AWSの後片付け
```
terraform destory
```
