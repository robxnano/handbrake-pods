# syntax=docker/dockerfile:1
FROM clearlinux:latest as base
ARG GIT_REPO=HandBrake
ARG GIT_TAG=master
# dependencies for Linux CLI
RUN swupd update && \
swupd bundle-add dev-utils dev-utils-dev devpkg-fribidi devpkg-jansson devpkg-libass devpkg-libjpeg-turbo devpkg-libogg devpkg-libsamplerate devpkg-libtheora devpkg-libvorbis devpkg-libvpx devpkg-opus devpkg-speex && \
curl -LO https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz && \
tar -xf lame-3.100.tar.gz && \
cd lame-3.100 && \
./configure --enable-shared --enable-static --enable-nasm && \
make -j$(nproc) && \
make install-strip && \
cd .. && \
curl -LO https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.bz2 && \
tar -xf x264-master.tar.bz2 && \
cd x264-master && \
./configure --enable-shared --enable-static --enable-lto --enable-pic --enable-strip && \
make -j$(nproc) && \
make install && \
cd .. && \
if ! grep '\/usr\/local\/lib' /etc/ld.so.conf >/dev/null 2>&1; then \
    export CFLAGS="${CFLAGS:-} -I/usr/local/include" && \
    export LDFLAGS="${LDFLAGS:-} -L/usr/local/lib" && \
    echo 'export CFLAGS="${CFLAGS:-} -I/usr/local/include"' >> "${HOME}/.bashrc"  && \
    echo 'export LDFLAGS="${LDFLAGS:-} -L/usr/local/lib"' >> "${HOME}/.bashrc" && \
    echo '/usr/local/lib' | tee --append /etc/ld.so.conf && \
    ldconfig ; \
fi && \
swupd bundle-add devpkg-libva devpkg-libdrm
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
RUN swupd bundle-add desktop-dev
# end of dependencies
RUN ./configure --enable-qsv --enable-nvenc --enable-vce --force --prefix="${PREFIX}" && \
make -C build -j${JOBS}

FROM test as install
RUN make -C build DESTDIR=/install install && \
make -C build install

FROM scratch as binaries-cli
COPY --from=install-cli /install /

FROM scratch as binaries
COPY --from=install /install /
