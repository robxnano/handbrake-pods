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
RUN apt-get install -y appstream desktop-file-utils gstreamer1.0-libav gstreamer1.0-plugins-good libgstreamer-plugins-base1.0-dev libgtk-3-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install && \
make -C build install
WORKDIR /install
RUN tar -cJf /handbrake-bin.tar.xz "`ls`"

FROM install as build-appimage
RUN rm -f /install/usr/bin/HandBrakeCLI && \
curl -LO https://github.com/linuxdeploy/linuxdeploy/releases/download/1-alpha-20220822-1/linuxdeploy-x86_64.AppImage && \
curl -LO https://github.com/linuxdeploy/linuxdeploy-plugin-gtk/raw/master/linuxdeploy-plugin-gtk.sh && \
chmod +x linuxdeploy-* && \
./linuxdeploy-x86_64.AppImage --appimage-extract && \
squashfs-root/AppRun --appdir /install --library /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0 --plugin gtk --output appimage

FROM scratch as appimage
COPY --from=build-appimage /HandBrake/HandBrake*.AppImage /

FROM scratch as binaries-cli
COPY --from=install-cli /install/handbrake-cli-bin.tar.xz /

FROM scratch as binaries
COPY --from=install /handbrake-bin.tar.xz /
