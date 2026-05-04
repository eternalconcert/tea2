FROM ubuntu:24.04

ARG BUILD_NO
ENV BUILD_NO=${BUILD_NO}

WORKDIR /app
ADD tea .
ADD example/ /app/example/
ADD common/ /app/example/teahouse/common/

WORKDIR /app/example

EXPOSE 5000
CMD ["/app/example/server.t"]
