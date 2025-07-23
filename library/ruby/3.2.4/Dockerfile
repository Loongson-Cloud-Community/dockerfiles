FROM cr.loongnix.cn/library/debian:buster

RUN set -eux; \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf bison build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libyaml-dev libncurses5-dev libffi-dev \
    libgdbm-dev libdb-dev wget && \
  \
  wget https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.4.tar.gz && \
  echo "c72b3c5c30482dca18b0f868c9075f3f47d8168eaf626d4e682ce5b59c858692 ruby-3.2.4.tar.gz" | sha256sum --check --strict && \
  tar -xzf ruby-3.2.4.tar.gz && \
  cd ruby-3.2.4 && \
  ./configure \
    --prefix=/usr/local \
    --enable-shared \
    --disable-install-doc \
    --with-opt-dir=/usr/local/lib \
    --host=loongarch64-linux-gnu \
    CFLAGS="-march=loongarch64 -O2" && \
  make -j$(nproc) && \
  make install && \

  # remove useless files
  cd / && \
  rm -rf ruby-3.2.4 && \
  rm -rf ruby-3.2.4.tar.gz && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/*

# Default command (keep container running)
CMD ["irb"]
