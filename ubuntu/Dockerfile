# syntax=docker/dockerfile:1
FROM ubuntu:latest as base
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN apt-get update && \
apt-get install -y appstream autoconf automake autopoint build-essential cmake git libass-dev libbz2-dev libfontconfig1-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libjansson-dev liblzma-dev libmp3lame-dev libnuma-dev libogg-dev libopus-dev libsamplerate-dev libspeex-dev libtheora-dev libtool libtool-bin libturbojpeg0-dev libvorbis-dev libx264-dev libxml2-dev libvpx-dev m4 make meson nasm ninja-build patch pkg-config tar zlib1g-dev && \
apt-get install -y libva-dev libdrm-dev
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
RUN apt-get install -y gettext gstreamer1.0-libav libdbus-glib-1-dev libglib2.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk-3-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /

