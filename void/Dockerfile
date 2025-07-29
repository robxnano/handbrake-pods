# syntax=docker/dockerfile:1
FROM ghcr.io/void-linux/void-musl:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN xbps-install -Syu autoconf automake bzip2-devel cmake diffutils fontconfig-devel file findutils freetype-devel fribidi-devel git gcc gzip harfbuzz-devel jansson-devel lame-devel lbzip2 libass-devel libflac-devel libjpeg-turbo-devel liblzma-devel libnuma-devel libogg-devel libsamplerate-devel libtheora-devel libtool libvorbis-devel libvpx-devel libxml2-devel m4 make meson nasm ninja opus-devel patch pkg-config python3 speex-devel tar x264-devel && \
xbps-install -Syu libva-devel libdrm-devel
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
RUN xbps-install -Syu desktop-file-utils gettext gst-libav gst-plugins-good1 gtk4-devel
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
