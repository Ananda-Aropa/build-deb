# syntax=docker/dockerfile:1-labs

# BUILD
FROM debian:latest AS builder

COPY . /build
WORKDIR /build

# Build binary package
RUN ./action_build.sh

# EXPORT
FROM scratch AS export

COPY --from=builder /artifacts/* /