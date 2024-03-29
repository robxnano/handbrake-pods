# syntax=docker/dockerfile:1
FROM fedora:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Windows CLI and hb.dll
RUN dnf install -y autoconf automake binutils bzip2 cargo cargo-c clang cmake diffutils mingw64-gcc-c++ git libtool m4 make meson nasm ninja-build patch pkgconf python rust rust-std-static-x86_64-pc-windows-gnu tar xz
# end of dependencies
RUN useradd -ms /usr/bin/bash runner
USER runner
WORKDIR /home/runner
RUN git clone "https://github.com/$GIT_REPO/HandBrake.git" --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=0
RUN ./configure --enable-qsv --enable-nvenc --enable-nvdec --enable-vce --enable-libdovi --cross=x86_64-w64-mingw32 --launch-jobs=${JOBS} --launch

FROM test-cli as install-cli
RUN make -C build pkg.create.zip

FROM scratch as binaries-cli
COPY --from=install-cli /home/runner/HandBrake/build/pkg/*.zip /