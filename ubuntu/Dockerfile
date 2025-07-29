# syntax=docker/dockerfile:1
FROM ubuntu:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && \
apt-get install -y autoconf automake build-essential cmake git libass-dev libbz2-dev libfontconfig-dev libfreetype-dev libfribidi-dev libharfbuzz-dev libjansson-dev liblzma-dev libmp3lame-dev libnuma-dev libogg-dev libopus-dev libsamplerate0-dev libspeex-dev libtheora-dev libtool libtool-bin libturbojpeg0-dev libvorbis-dev libx264-dev libxml2-dev libvpx-dev m4 make meson nasm ninja-build patch pkg-config tar zlib1g-dev && \
apt-get install -y libva-dev libdrm-dev
# end of dependencies
RUN git clone "https://github.com/$GIT_REPO/HandBrake.git" --depth 1 --branch "$GIT_TAG"
WORKDIR HandBrake

FROM base as test-cli
ARG JOBS=6
ARG PREFIX=/usr/local
ARG EXTRA_ARGS=
RUN ./configure --disable-gtk --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" ${EXTRA_ARGS} && \
make -C build -j${JOBS}

FROM test-cli as install-cli
RUN make -C build DESTDIR=/install install
WORKDIR /install
RUN tar -czf /handbrake-cli-bin.tar.gz "`ls`"

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
ARG EXTRA_ARGS=
# dependencies for GTK GUI
RUN apt-get install -y appstream desktop-file-utils gettext gstreamer1.0-libav gstreamer1.0-plugins-good libgtk-4-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" ${EXTRA_ARGS} && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install && \
make -C build install
WORKDIR /install
RUN tar -czf /handbrake-bin.tar.gz "`ls`"

FROM install as build-appimage
WORKDIR /linuxdeploy
RUN rm -f /install/usr/bin/HandBrakeCLI && \
curl -LO https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20250213-2/linuxdeploy-x86_64.AppImage && \
curl -LO https://github.com/linuxdeploy/linuxdeploy-plugin-gtk/raw/master/linuxdeploy-plugin-gtk.sh && \
chmod +x linuxdeploy-* && \
./linuxdeploy-x86_64.AppImage --appimage-extract-and-run --appdir /install --plugin gtk --output appimage

FROM scratch as appimage
COPY --from=build-appimage /linuxdeploy/HandBrake*.AppImage /

FROM scratch as binaries-cli
COPY --from=install-cli /install/handbrake-cli-bin.tar.gz /

FROM scratch as binaries
COPY --from=install /handbrake-bin.tar.gz /
