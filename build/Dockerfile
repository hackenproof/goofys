ARG GO_SOURCES=/go/src/github.com/kahing/goofys

FROM golang:1.16 as base_go_docker_image
ARG GO_SOURCES
ARG CGO_ENABLED=0
ARG GOOS=linux
# For build from original sources
#RUN go get github.com/kahing/goofys
WORKDIR $GO_SOURCES
COPY . $GO_SOURCES
RUN go build -v -o $GO_SOURCES/goofys .

FROM alpine
LABEL org.opencontainers.image.authors="Ruslan Bobrovnikov <ruslan.bobrovnikov@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/hackenproof/goofys"
ARG GO_SOURCES
RUN apk add --update --no-cache ca-certificates fuse fuse-dev
COPY --from=base_go_docker_image $GO_SOURCES/goofys /goofys
RUN echo user_allow_other >> /etc/fuse.conf
USER nobody
ENTRYPOINT ["/goofys"]
