FROM golang:1.14 AS build

ENV GO111MODULE=on \
    GOOS=linux \
    GOARCH=amd64

RUN mkdir -p /src

COPY go.sum go.mod /src/

WORKDIR /src

RUN go mod download

COPY . /src

RUN go install -installsuffix cgo -ldflags="-w -s" && \
    mkdir -p /app && \
    cp -r $GOPATH/bin/golang-echo-realworld-example-app /app/

FROM frolvlad/alpine-glibc:alpine-3.12

ENV TZ=Asia/Jerusalem \
    PATH="/app:${PATH}"

RUN apk add --update --no-cache \
    sqlite \
    tzdata \
    ca-certificates \
    bash \
    && \
    cp --remove-destination /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

WORKDIR /app

COPY --from=build /app /app/

EXPOSE 8585

CMD ["./golang-echo-realworld-example-app"]
