FROM golang:1.17.6 as builder

COPY go.mod /go/src/github.com/siangyeh8818/golang-http-proxy-k8s/go.mod
COPY go.sum /go/src/github.com/siangyeh8818/golang-http-proxy-k8s/go.sum

# Run golang at any directory, not neccessary $GOROOT, $GOPATH
ENV GO111MODULE=on
WORKDIR /go/src/github.com/siangyeh8818/golang-http-proxy-k8s

# RUN go mod init github.com/pnetwork/sre.monitor.metrics
RUN go mod download
COPY main.go /go/src/github.com/siangyeh8818/golang-http-proxy-k8s
COPY internal /go/src/github.com/siangyeh8818/golang-http-proxy-k8s/internal
#COPY pkg /go/src/github.com/pnetwork/sre.monitor.metrics/pkg

# Build the Go app
RUN env GOOS=linux GOARCH=amd64 go build -o golang-http-proxy-k8s -v -ldflags "-s" github.com/siangyeh8818/golang-http-proxy-k8s/

##### To reduce the final image size, start a new stage with alpine from scratch #####

FROM alpine:3.15
RUN apk --no-cache add ca-certificates libc6-compat busybox-extras

# Run as root
WORKDIR /root/

# Copy the pre-built binary file from the previous stage
COPY --from=builder /go/src/github.com/siangyeh8818/golang-http-proxy-k8s  /usr/local/bin/golang-http-proxy-k8s 

# EXPOSE 8081

ENTRYPOINT [ "golang-http-proxy-k8s" ] 
