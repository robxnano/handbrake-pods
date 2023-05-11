# syntax=docker/dockerfile:1
FROM opensuse/leap:latest as base
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN zypper in -y AppStream autoconf automake binutils bzip2 cmake fontconfig-devel freetype-devel fribidi-devel gcc-c++ git gzip harfbuzz-devel lbzip2 libass-devel libjansson-devel libjpeg8-devel libmp3lame-devel libnuma-devel libogg-devel libopus-devel libsamplerate-devel libtheora-devel libtool libvorbis-devel libxml2-devel libvpx-devel m4 make meson nasm ninja patch pkgconf-pkg-config python speex-devel tar xz-devel zimg-devel zlib-devel && \
if grep "opensuse-tumbleweed" /etc/os-release ; then \
    zypper ar -cfp 90 'https://ftp.fau.de/packman/suse/openSUSE_Tumbleweed/Essentials' packman-essentials ; \
elif grep "opensuse-leap" /etc/os-release ; then \
    zypper ar -cfp 90 'https://ftp.fau.de/packman/suse/openSUSE_Leap_$releasever/Essentials' packman-essentials ; \
else \
    echo "Error: OS image unsupported"; exit 1; \
fi && \
zypper --gpg-auto-import-keys dup -y --from packman-essentials --allow-vendor-change && \
zypper install -y libx264-devel && \
zypper install -y libva-devel libdrm-devel
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
RUN zypper install -y dbus-1-glib-devel gstreamer-devel gstreamer-plugins-base-devel gstreamer-plugins-libav gtk3-devel
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /