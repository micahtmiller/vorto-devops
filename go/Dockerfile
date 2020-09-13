FROM golang:1.14

WORKDIR /go/src/go_server

COPY src/go_server .
RUN go install go_server

CMD [ "go_server" ]

EXPOSE 8080