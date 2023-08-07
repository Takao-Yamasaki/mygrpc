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
## 事前準備
- IAMユーザーを作成しておくこと
- AWS CLIを使用するので、IAM作成後、次のコマンドで認証設定をしておくこと
- https://avinton.com/academy/aws-cli-install-setting/
```
aws configure
```

## ECRのレポジトリを作成
AWS CLIを使用して、レポジトリを作成
- ECRを作成
```
aws ecr create-repository --repository-name mygrpc
```
- ECRが作成されたかどうか確認。プライベートリポジトリに作成される。
```
aws ecr describe-repositories --repository-name mygrpc
```

## イメージをECRにプッシュ
AWS CLIを使用して、ECRにイメージプッシュ
- [Amazon ECR][リポジトリ][mygrpc][プッシュコマンドの表示]を押下し、表示されるコマンドをAWS CLIで実行していく
- 1.認証トークンを取得し、レジストリに対して Dockerクライアントを認証します。
- 2.以下のコマンドを使用して、Dockerイメージを構築
```
make build-prod
```
- 3.構築が完了したら、このリポジトリにイメージをプッシュできるように、イメージにタグを付け
- 4.新しく作成した AWS リポジトリにこのイメージをプッシュ
- https://dev.classmethod.jp/articles/beginner-series-to-check-how-t-create-docker-image-and-push-to-amazon-ecr/
### 参考


## Route53でドメインを取得
## ACMでHTTPS化
