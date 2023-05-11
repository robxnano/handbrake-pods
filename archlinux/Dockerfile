# syntax=docker/dockerfile:1
FROM archlinux:latest as base
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN pacman -Syu --noconfirm base-devel cmake flac fontconfig freetype2 fribidi git harfbuzz jansson lame libass libbluray libjpeg-turbo libogg libsamplerate libtheora libvorbis libvpx libxml2 meson nasm ninja numactl opus python speex x264 xz && \
pacman -Syu --noconfirm libva libdrm
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
RUN pacman -Syu --noconfirm dbus-glib gstreamer gst-libav gst-plugins-base gtk3
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /
