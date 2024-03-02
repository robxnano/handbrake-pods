# syntax=docker/dockerfile:1
FROM archlinux:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN pacman -Syu --noconfirm base-devel cmake flac fontconfig freetype2 fribidi git harfbuzz jansson lame libass libbluray libjpeg-turbo libogg libsamplerate libtheora libvorbis libvpx libxml2 meson nasm ninja numactl opus python speex x264 xz && \
pacman -Syu --noconfirm libva libdrm
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
RUN tar -czf /handbrake-cli-bin.tar.gz "`ls`"

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
# dependencies for GTK GUI
RUN pacman -Syu --noconfirm desktop-file-utils gst-libav gst-plugins-good gtk4
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
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
