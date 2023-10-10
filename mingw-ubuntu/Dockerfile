# syntax=docker/dockerfile:1
FROM ubuntu:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Windows CLI and hb.dll
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
apt-get install -y autoconf automake build-essential clang cmake curl g++-mingw-w64-x86-64 gcc-mingw-w64-x86-64 git libssl-dev libtool libtool-bin m4 make meson nasm ninja-build patch pkg-config tar zip
# end of dependencies
RUN useradd -ms /usr/bin/bash runner
USER runner
WORKDIR /home/runner
ENV PATH /home/runner/.cargo/bin:${PATH}
RUN curl https://sh.rustup.rs | sh -s -- -y --profile minimal --target x86_64-pc-windows-gnu && \
cargo install cargo-c
RUN git clone "https://github.com/$GIT_REPO/HandBrake.git" --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=0
RUN ./configure --enable-qsv --enable-nvenc --enable-nvdec --enable-vce --enable-libdovi --cross=x86_64-w64-mingw32 --launch-jobs=${JOBS} --launch

FROM test-cli as install-cli
RUN make -C build pkg.create.zip

FROM scratch as binaries-cli
COPY --from=install-cli /home/runner/HandBrake/build/pkg/*.zip /