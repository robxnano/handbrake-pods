# syntax=docker/dockerfile:1
FROM alpine:latest as base
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN apk add autoconf automake busybox cmake g++ git jansson-dev lame-dev libass-dev libjpeg-turbo-dev libtheora-dev libvorbis-dev libxml2-dev m4 make nasm ninja numactl-dev opus-dev pkgconf python3 speex-dev x264-dev && \
apk add libva-dev libdrm-dev
# end of dependencies
RUN git clone https://github.com/HandBrake/HandBrake.git --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=6
ARG PREFIX=/usr/local
RUN ./configure --disable-gtk --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test-cli as install-cli
RUN make -C build DESTDIR=/install install

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
# dependencies for GTK GUI
RUN apk add gstreamer-dev gst-plugins-base-dev gst-plugins-good gtk+3.0-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /

Alpine Linux


