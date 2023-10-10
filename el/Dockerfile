# syntax=docker/dockerfile:1
FROM almalinux:9 as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN dnf install -y autoconf automake bzip2 cmake diffutils dnf-plugins-core fribidi-devel gcc-c++ git libtool libxml2-devel m4 make numactl-devel patch pkg-config python39 tar xz-devel && \
dnf config-manager --set-enabled crb || dnf config-manager --set-enabled powertools && \
dnf install -y jansson-devel lame-devel libogg-devel libsamplerate-devel libtheora-devel libvorbis-devel libvpx-devel meson nasm ninja-build opus-devel speex-devel turbojpeg-devel && \
if grep "CentOS Stream" /etc/os-release ; then \
    dnf install -y epel-next-release ; \
else \
    dnf install -y epel-release ; \
fi && \
dnf install -y libass-devel && \
dnf localinstall -y --nogpgcheck https://download1.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm && \
dnf install -y x264-devel && \
dnf install -y libva-devel libdrm-devel
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

FROM test-cli as test
ARG JOBS=6
ARG PREFIX=/usr/local
# dependencies for GTK GUI
RUN dnf install -y appstream gettext-devel gstreamer1-devel gstreamer1-libav gstreamer1-plugins-base-devel gtk3-devel
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /
