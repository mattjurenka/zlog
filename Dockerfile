# Build Stage
FROM --platform=linux/amd64 ubuntu:latest as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang

## Add source code to the build stage.
ADD . /zlog/
WORKDIR /zlog/

ENV CC=/bin/clang
ENV CCX=/bin/clang

## TODO: ADD YOUR BUILD INSTRUCTIONS HERE.
RUN make
RUN make install
RUN ldconfig

WORKDIR /zlog/test/fuzzers/
RUN clang -fsanitize=fuzzer,address -fno-inline zlog_init_fuzzer.c /zlog/src/libzlog.a -o fuzzme
RUN ldconfig

FROM --platform=linux/amd64 ubuntu:latest
## TODO: Change <Path in Builder Stage>
COPY --from=builder /zlog/test/fuzzers/fuzzme /

ENTRYPOINT []
CMD /fuzzme
