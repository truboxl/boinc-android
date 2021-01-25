#!/bin/sh
# with modification from Termux own build scripts
# https://github.com/termux/termux-packages/blob/master/packages/libtalloc/build.sh
# https://github.com/termux/termux-packages/blob/master/packages/proot/build.sh
#
# original proot can be found at https://github.com/proot-me/proot
#
# note we are using Termux fork of proot for Android compatibility
# https://github.com/termux/proot
#
# requires at least API=23 but breaks at targetSdkVersion 29
set -e

REPO_DIR="$PWD"

mkdir -p "$REPO_DIR/src/"
cd "$REPO_DIR/src/"

##### prepare sources #####

echo 'Preparing libtalloc 2.3.1 sources'
curl -#LOC - https://www.samba.org/ftp/talloc/talloc-2.3.1.tar.gz
tar xf talloc-2.3.1.tar.gz

echo 'Preparing proot sources'
if [ -d ./proot ]; then
    echo 'proot repo seems to be available, moving on'
else
    git clone https://github.com/termux/proot
fi

##### build #####

echo '===== proot build for all platforms start ====='

build() {
    LIBTALLOC_DIR="${REPO_DIR}/buildcache/libtalloc-${ARCH}-${API}"

    echo "===== libtalloc build for ${TARGET} (${ABI}) start ====="

    cd "$REPO_DIR/src/talloc-2.3.1/"

    tee cross-answers.txt << EOF > /dev/null
Checking uname sysname type: "Linux"
Checking uname machine type: "dontcare"
Checking uname release type: "dontcare"
Checking uname version type: "dontcare"
Checking simple C program: OK
building library support: OK
Checking for large file support: OK
Checking for -D_FILE_OFFSET_BITS=64: OK
Checking for WORDS_BIGENDIAN: OK
Checking for C99 vsnprintf: OK
Checking for HAVE_SECURE_MKSTEMP: OK
rpath library support: OK
-Wl,--version-script support: FAIL
Checking correct behavior of strtoll: OK
Checking correct behavior of strptime: OK
Checking for HAVE_IFACE_GETIFADDRS: OK
Checking for HAVE_IFACE_IFCONF: OK
Checking for HAVE_IFACE_IFREQ: OK
Checking getconf LFS_CFLAGS: OK
Checking for large file support without additional flags: OK
Checking for working strptime: OK
Checking for HAVE_SHARED_MMAP: OK
Checking for HAVE_MREMAP: OK
Checking for HAVE_INCOHERENT_MMAP: OK
Checking getconf large file support flags work: OK
EOF

    ./configure --prefix="${LIBTALLOC_DIR}" \
                --cross-compile \
                --cross-answers=cross-answers.txt  \
                --disable-python \
                --disable-rpath
    
    make clean

    make install

    # libtalloc doesn't build static libraries automatically yet
    cd ./bin/default
    $AR rcu libtalloc.a talloc*.o
    install -Dm644 libtalloc.a "${LIBTALLOC_DIR}/lib/libtalloc.a"

    echo "===== libtalloc build for ${TARGET} (${ABI}) done ====="

    echo "===== proot build for ${TARGET} (${ABI}) start ====="

    cd "$REPO_DIR/src/proot/src"

    make clean

    make CFLAGS="$CFLAGS -I${LIBTALLOC_DIR}/include" LDFLAGS="$LDFLAGS ${LIBTALLOC_DIR}/lib/libtalloc.a" #CPPFLAGS="$CPPFLAGS -DARG_MAX=131072"

    mkdir -p "$REPO_DIR/buildcache/proot-$ARCH-$API"
    if [ -z "$APP_DEBUG" ]; then
        echo 'Stripping proot binary'
        "$STRIP" -v ./proot
    fi
    cp -f ./proot "$REPO_DIR/buildcache/proot-$ARCH-$API/proot"

    echo "===== proot build for ${TARGET} (${ABI}) done ====="
}

##### main script #####

cd "$REPO_DIR"

for arch in aarch64 arm x86_64 x86; do
    API=23
    ARCH="$arch"
    . ./set-env.sh
    build
    cd "$REPO_DIR"
    . ./unset-env.sh
done

echo '===== proot build for all platforms done ====='

# adding proot support to BOINC is experimental and require patches
# patches are available at truboxl/boinc-termux-client
