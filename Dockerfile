FROM alpine:latest AS build

RUN apk --no-cache add \
    build-base pkgconfig curl-dev linux-headers \
    brotli-dev cmake ca-certificates crc32c-dev fmt-dev \
    git libpsl npm libnatpmp-dev \
    libevent-dev gettext-dev xz ninja libdeflate-dev \
    openssl-dev zlib-dev

WORKDIR /app
RUN git clone -b 4.0.5 --recurse-submodules --depth 1 https://github.com/transmission/transmission.git src
RUN ls -la

RUN cmake \
            -S src \
            -B obj \
            -G Ninja \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DCMAKE_INSTALL_PREFIX=pfx \
            -DENABLE_CLI=ON \
            -DENABLE_DAEMON=ON \
            -DENABLE_GTK=OFF \
            -DENABLE_MAC=OFF \
            -DENABLE_QT=OFF \
            -DENABLE_TESTS=OFF \
            -DENABLE_UTILS=ON \
            -DREBUILD_WEB=OFF \
            -DENABLE_WERROR=ON \
            -DRUN_CLANG_TIDY=OFF \
            -DUSE_SYSTEM_CRC32C=ON \
            -DUSE_SYSTEM_DHT=OFF \
            -DUSE_SYSTEM_MINIUPNPC=OFF

RUN cmake --build obj --config RelWithDebInfo

RUN git clone --depth 1 https://github.com/ronggang/transmission-web-control.git webcontrol


FROM alpine:latest AS runtime

RUN apk --no-cache add \
    ca-certificates libevent openssl zlib libpsl curl libnatpmp brotli crc32c libdeflate libintl
WORKDIR /transmission
RUN mkdir /transmission/config
RUN chmod -R 1777 /transmission
COPY --from=build /app/obj/daemon/transmission-daemon /bin/
COPY --from=build /app/obj/cli/transmission-cli /bin/
COPY --from=build /app/obj/utils/transmission-create /bin/
COPY --from=build /app/obj/utils/transmission-edit /bin/
COPY --from=build /app/obj/utils/transmission-remote /bin/
COPY --from=build /app/obj/utils/transmission-show /bin/
COPY --from=build /app/src/web/public_html /transmission/public_html
RUN mv /transmission/public_html/index.html /transmission/public_html/index.original.html
COPY --from=build /app/webcontrol/src /transmission/public_html
#RUN cp /transmission/public_html/index.html /transmission/webcontrol/index.original.html

ENV TRANSMISSION_WEB_HOME=/transmission/public_html

ENTRYPOINT [ "/bin/transmission-daemon", "--foreground", "--config-dir", "/transmission/config" ]
