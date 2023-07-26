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
