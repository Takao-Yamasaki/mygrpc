#  開発用のコンテナ
FROM golang:1.18-alpine as base
ENV ROOT=/go/src/project
RUN apk add --no-cache protobuf make
WORKDIR ${ROOT}
COPY go.mod go.sum ${ROOT}/
RUN go mod download
CMD [ "/bin/sh" ]

# イメージのビルド用
FROM golang:1.18-alpine as build
ENV ROOT=/go/src/project
WORKDIR ${ROOT}

COPY . ${ROOT}
RUN go mod download \
  && CGO=ENABLED=0 GOOS=linux go build -o server ./cmd/server

# prod用のコンテナ
FROM alpine:3.15.4 as prod
ENV ROOT=/go/src/project
WORKDIR ${ROOT}

RUN addgroup -S dockergroup && adduser -S docker -G dockergroup
USER docker

COPY --from=build ${ROOT}/server ${ROOT}
EXPOSE 8080
CMD ["./server"]
