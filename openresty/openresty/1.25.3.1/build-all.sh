#!/bin/sh -e

##
## @fn build-all.sh
##
## dependencies.
##

install_from_source() {

    URL="$1"
    VERSION="$2"
    shift 2

    SOURCE_FILE="$(basename "$URL")"
    SOURCE_DIR="$(basename "$URL" .tar.gz)"

    if [ "$VERSION" = "NO" ]; then
        echo "NOT building $SOURCE_DIR (explicitly skipped)"
        return
    fi

    cd /tmp
    curl -fSL "$URL" -o "$SOURCE_FILE"
    tar -xf "$SOURCE_FILE"

    cd $SOURCE_DIR/

    echo "Building $REPO_DIR @ $VERSION ..."

    # Patch OpenSSL
    if echo "$SOURCE_DIR" | grep -q "openssl"; then
        if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.1" ]; then
            echo 'patching OpenSSL 1.1.1 for OpenResty'
            curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1
        fi
        if [ $(echo ${RESTY_OPENSSL_VERSION} | cut -c 1-5) = "1.1.0" ]; then
            echo 'patching OpenSSL 1.1.0 for OpenResty'
            curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1
            curl -s https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-${RESTY_OPENSSL_PATCH_VERSION}-sess_set_get_cb_yield.patch | patch -p1
        fi
    fi

    # Patch LoongArch64
    if [ "$BUILD_ARCHITECTURE" = "loongarch64" ]; then
        if echo "$SOURCE_DIR" | grep -q "pcre"; then
            echo 'patching PCRE for LoongArch64'
            rm -f config.guess config.sub
            curl -fSL 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD' -o config.guess
            curl -fSL 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD' -o config.sub
        fi

        if echo "$SOURCE_DIR" | grep -q "openresty"; then
            echo 'patching LuaJIT for LoongArch64'
            LuaJIT_VERSION=v2.1-agentzh-loongarch64
            LuaJIT_DIR=bundle/LuaJIT-*
            rm -rf ${LuaJIT_DIR:?}/*
            curl -fSL https://github.com/Loongson-Cloud-Community/luajit2/archive/refs/heads/${LuaJIT_VERSION}.tar.gz | tar -zxf - -C ${LuaJIT_DIR} --strip-components 1
        fi
    fi

    if [ -e config ]; then
        ./config "$@"
    elif [ -e configure ]; then
        if echo "$SOURCE_DIR" | grep -q "openresty"; then
            eval ./configure "$@"
        else
            ./configure "$@"
        fi
    else
        echo "No build configuration script found"
        exit 1
    fi

    make -j$(nproc) && make install

}

export BUILD_ARCHITECTURE="$(arch)"
echo "Build architecture: $BUILD_ARCHITECTURE"

case $BUILD_ARCHITECTURE in
    x86_64|aarch64)
        export PCRE_OPTS_OVERRIDES="--enable-jit"
        export OPENRESTY_OPTS_OVERRIDES="--with-pcre-jit"
        ;;
    armv7l)
        export OPENSSL_OPTS_OVERRIDES="-march=armv7-a+fp"
        ;;
    *)
        export OPENSSL_OPTS_OVERRIDES=""
        export PCRE_OPTS_OVERRIDES=""
        export OPENRESTY_OPTS_OVERRIDES=""
        ;;
esac

#
# Build and install dependencies
#

install_from_source "${RESTY_OPENSSL_URL_BASE}/openssl-${RESTY_OPENSSL_VERSION}.tar.gz" "$RESTY_OPENSSL_VERSION" $OPENSSL_OPTS $OPENSSL_OPTS_OVERRIDES
install_from_source "https://downloads.sourceforge.net/project/pcre/pcre/${RESTY_PCRE_VERSION}/pcre-${RESTY_PCRE_VERSION}.tar.gz" "$RESTY_PCRE_VERSION" $PCRE_OPTS $PCRE_OPTS_OVERRIDES
install_from_source "https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz" "$RESTY_VERSION" $OPENRESTY_OPTS $OPENRESTY_OPTS_OVERRIDES
install_from_source "https://luarocks.github.io/luarocks/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz" "$RESTY_LUAROCKS_VERSION" $LUAROCKS_OPTS