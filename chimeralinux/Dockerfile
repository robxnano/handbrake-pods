# syntax=docker/dockerfile:1
FROM chimeralinux/chimera:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN apk add autoconf automake bsdtar chimerautils-extra clang cmake git gm4 gmake jansson-devel lame-devel libass-devel libjpeg-turbo-devel libnuma-devel libtheora-devel libtool libvorbis-devel libvpx-devel libxml2-devel meson nasm ninja opus-devel pkgconf python speex-devel x264-devel && \
apk add libva-devel libdrm-devel
# end of dependencies
RUN git clone "https://github.com/$GIT_REPO/HandBrake.git" --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=6
ARG PREFIX=/usr/local
RUN CC=clang CXX=clang++ ./configure --disable-gtk --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test-cli as install-cli
RUN make -C build DESTDIR=/install install
WORKDIR /install
RUN tar -czf /handbrake-cli-bin.tar.gz "`ls`"

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
# dependencies for GTK GUI
RUN apk add desktop-file-utils gettext gst-libav gst-plugins-good gtk4-devel
# end of dependencies
RUN CC=clang CXX=clang++ ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install && \
make -C build install
WORKDIR /install
RUN tar -czf /handbrake-bin.tar.gz "`ls`"

FROM scratch as binaries-cli
COPY --from=install-cli /handbrake-cli-bin.tar.gz /

FROM scratch as binaries
COPY --from=install /handbrake-bin.tar.gz /
