.PHONY: help go unary server install client protoc
help: ## Display this help screen
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
open: ## Open DevContaienr
	@devcontainer open .
up: ## Start Container
	@docker-compose up -d
down: ## Stop Container
	@docker-compose down
exec: ## Login Container
	@docker-compose exec go sh
install: ## Install Go Plugin for Protobuf
	@go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28 && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
ps: ## Check Container Status
	@docker-compose ps
protoc: ## Proto-Compiler for Go 
	@protoc --go_out=pkg/grpc --go_opt=paths=source_relative \
			--go-grpc_out=pkg/grpc --go-grpc_opt=paths=source_relative \
      api/hello.proto
build-prod: ## Build Image for Production
	@docker build --target prod -t mygrpc:latest .
run-prod: ## Start Container for Production
	@docker run -d --name mygrpc -p 8080:8080 mygrpc:latest
exec-prod: ## Login Container for Production
	@docker exec -it mygrpc sh
mod: ## Install modules
	@go mod tidy
server: ## Start Server
	@docker-compose exec go go run cmd/server/main.go
client: ## Start Client
	@go run client/main.go
middleware: ## Install go-grpc-middleware
	@go get github.com/grpc-ecosystem/go-grpc-middleware
service: ## Show Service-list
	@docker compose run grpcurl -plaintext go:8080 list
method: ## Show Method-list
	@docker compose run grpcurl -plaintext go:8080 list myapp.GreetingService
callmethod: ## Call Method
	@docker compose run grpcurl -plaintext -d '{"name": "hsaki"}' go:8080 myapp.GreetingService.Hello
