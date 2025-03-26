FROM cr.loongnix.cn/library/debian:buster

RUN set -eux; \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf bison build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libyaml-dev libncurses5-dev libffi-dev \
    libgdbm-dev libdb-dev wget && \
  \
  wget https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.7.tar.gz && \
  echo "9c37c3b12288c7aec20ca121ce76845be5bb5d77662a24919651aaf1d12c8628 ruby-3.3.7.tar.gz" | sha256sum --check --strict && \
  tar -xzf ruby-3.3.7.tar.gz && \
  cd ruby-3.3.7 && \
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
  rm -rf ruby-3.3.7 && \
  rm -rf ruby-3.3.7.tar.gz && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/*

# Default command (keep container running)
CMD ["irb"]
