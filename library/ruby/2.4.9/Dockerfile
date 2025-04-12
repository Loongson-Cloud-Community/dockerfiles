FROM cr.loongnix.cn/library/debian:buster

RUN set -eux; \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    autoconf bison build-essential \
    libssl-dev libreadline-dev zlib1g-dev \
    libyaml-dev libncurses5-dev libffi-dev \
    libgdbm-dev libdb-dev wget && \
  \
  wget https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.9.tar.gz && \
  echo "f99b6b5e3aa53d579a49eb719dd0d3834d59124159a6d4351d1e039156b1c6ae ruby-2.4.9.tar.gz" | sha256sum --check --strict && \
  tar -xzf ruby-2.4.9.tar.gz && \
  cd ruby-2.4.9 && \
  # replace these file with loongnix patch
  rm tool/config.guess && \
  rm tool/config.sub && \
  wget -O tool/config.guess 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess' && \
  wget -O tool/config.sub 'https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub' && \
  chmod +x tool/config.guess tool/config.sub && \
  # compile
  ./configure \
    --host=loongarch64-linux-gnu \
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
  rm -rf ruby-2.4.9 && \
  rm -rf ruby-2.4.9.tar.gz && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/*

# Default command (keep container running)
CMD ["irb"]
