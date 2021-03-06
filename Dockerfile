FROM debian:stable-slim

RUN echo "deb http://ftp.ca.debian.org/debian unstable main" >> /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        cmake \
        build-essential \
        zlib1g-dev \
        python \
        wget \
        xz-utils \
        libxml2-dev
RUN apt-get install -y --no-install-recommends libxml2
RUN apt-get install -y --no-install-recommends python3-neovim 
RUN apt-get install -y --no-install-recommends sudo 
RUN apt-get install -y --no-install-recommends neovim 
RUN apt-get install -y --no-install-recommends curl
RUN apt-get install -y --no-install-recommends ca-certificates
RUN apt-get install -y --no-install-recommends fish

RUN mkdir -p /deps

# llvm
WORKDIR /deps
RUN wget http://releases.llvm.org/6.0.0/llvm-6.0.0.src.tar.xz
RUN tar xf llvm-6.0.0.src.tar.xz
RUN mkdir -p /deps/llvm-6.0.0.src/build
WORKDIR /deps/llvm-6.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local -DCMAKE_BUILD_TYPE=Release
RUN make -j4 install

# clang
WORKDIR /deps
RUN wget http://releases.llvm.org/6.0.0/cfe-6.0.0.src.tar.xz
RUN tar xf cfe-6.0.0.src.tar.xz
RUN mkdir -p /deps/cfe-6.0.0.src/build
WORKDIR /deps/cfe-6.0.0.src/build
RUN cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_PREFIX_PATH=/usr/local -DCMAKE_BUILD_TYPE=Release
RUN make -j4 install

# zig
ARG ZIG_BRANCH=master

WORKDIR /deps
ARG CACHE_DATE=2018-03-04
RUN git clone --branch $ZIG_BRANCH --depth 1 https://github.com/zig-lang/zig
RUN mkdir -p /deps/zig/build
WORKDIR /deps/zig/build
# Install to /usr and mirror this on the copy
RUN cmake .. \
    -DZIG_LIBC_LIB_DIR=$(dirname $(cc -print-file-name=crt1.o))            \
    -DZIG_LIBC_INCLUDE_DIR=$(echo -n | cc -E -x c - -v 2>&1 |              \
                             grep -B1 "End of search list." |              \
                             head -n1 | cut -c 2- | sed "s/ .*//")         \
    -DZIG_LIBC_STATIC_LIB_DIR=$(dirname $(cc -print-file-name=crtbegin.o)) \
    -DCMAKE_BUILD_TYPE=Release                                             \
    -DCMAKE_PREFIX_PATH=/deps/local                                        \
    -DCMAKE_INSTALL_PREFIX=/usr
RUN make install

RUN rm -rf /deps
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /z

