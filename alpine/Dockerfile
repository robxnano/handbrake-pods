# syntax=docker/dockerfile:1
FROM alpine:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN apk add autoconf automake busybox cmake g++ git jansson-dev lame-dev libass-dev libjpeg-turbo-dev libtheora-dev libtool libvorbis-dev libvpx-dev libxml2-dev m4 make meson nasm ninja numactl-dev opus-dev patch pkgconf python3 speex-dev tar x264-dev && \
apk add libva-dev libdrm-dev
# end of dependencies
RUN git clone "https://github.com/$GIT_REPO/HandBrake.git" --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=6
ARG PREFIX=/usr/local
RUN ./configure --disable-gtk --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test-cli as install-cli
RUN make -C build DESTDIR=/install install
WORKDIR /install
RUN tar -cJf /handbrake-cli-bin.tar.xz "`ls`"

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
# dependencies for GTK GUI
RUN apk add desktop-file-utils gst-libav gst-plugins-good gtk4.0-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install && \
make -C build install
WORKDIR /install
RUN tar -cJf /handbrake-bin.tar.xz "`ls`"

FROM scratch as binaries-cli
COPY --from=install-cli /handbrake-cli-bin.tar.xz /

FROM scratch as binaries
COPY --from=install /handbrake-bin.tar.xz /
