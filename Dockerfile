FROM golang:1.18-alpine

ENV ROOT=/go/src/project

RUN apk add --no-cache protobuf make

WORKDIR /go/src/project

COPY go.mod go.sum /go/src/project/

RUN go mod download

CMD [ "/bin/sh" ]
