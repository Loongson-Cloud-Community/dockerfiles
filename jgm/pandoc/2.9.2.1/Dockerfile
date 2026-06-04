FROM cr.loongnix.cn/library/debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       texlive-xetex \
       texlive-latex-recommended \
       texlive-fonts-recommended \
       texlive-latex-extra \
       texlive-lang-chinese \
       fonts-noto-cjk \
       fontconfig \
       lmodern \
    && fc-cache -fv \
    && rm -rf /var/lib/apt/lists/*

RUN wget -qO /tmp/pandoc-2.9.2.1-loongarch64-abi1.tar.gz http://cloud.loongnix.cn/releases/loongarch64abi1/jgm%2Fpandoc%2F2.9.2.1/pandoc-2.9.2.1-loongarch64-abi1.tar.gz

RUN tar -xzf /tmp/pandoc-2.9.2.1-loongarch64-abi1.tar.gz -C / \
 && rm /tmp/pandoc-2.9.2.1-loongarch64-abi1.tar.gz

ENV pandoc_datadir=/opt/pandoc/share/pandoc-2.9.2.1
ENV PATH="/usr/local/bin:${PATH}"
