FROM golang:1.14

ENV GOBIN=$GOPATH/bin

ADD src/go_server /go/src/go_server
RUN go install go_server

ENTRYPOINT /go/bin/go_server

EXPOSE 8080