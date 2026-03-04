# syntax=docker/dockerfile:1-labs

### BUILD
FROM debian:latest as builder

COPY . /build
WORKDIR /build

# Build binary package
RUN ./action_build.sh

### EXPORT
FROM scratch AS export

COPY --from=builder /*.deb /
COPY --from=builder /*.udeb /
COPY --from=builder /*.buildinfo /
COPY --from=builder /*.changes /