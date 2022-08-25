FROM cr.loongnix.cn/library/alpine:3.11.11

LABEL maintainer="wangweijie@loongson.cn"

RUN set -x \
	&& addgroup -g 82 -S www-data \
	&& adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine
 
ENV HTTPD_PREFIX /usr/local/apache2
ENV PATH $HTTPD_PREFIX/bin:$PATH
RUN mkdir -p "$HTTPD_PREFIX" \
	&& chown www-data:www-data "$HTTPD_PREFIX"
WORKDIR $HTTPD_PREFIX
 
ENV HTTPD_VERSION 2.4.46
ENV HTTPD_SHA256=740eddf6e1c641992b22359cabc66e6325868c3c5e2e3f98faf349b61ecf41ea

ENV HTTPD_PATCHES=""
 
ENV APACHE_DIST_URLS \
	https://www.apache.org/dyn/closer.cgi?action=download&filename= \
	https://www-us.apache.org/dist/ \
	https://www.apache.org/dist/ \
	https://archive.apache.org/dist/
 
RUN set -eux; \
	\
	runDeps=' \
		apr \
		apr-util \
		apr-util-ldap \
		perl \
	'; \
	apk add --no-cache --virtual .build-deps \
		$runDeps \
		apr-dev \
		apr-util-dev \
		ca-certificates \
		coreutils \
		dpkg-dev dpkg \
		gcc \
		gnupg \
		libc-dev \
		curl-dev \
		jansson-dev \
		# mod_proxy_html mod_xml2enc
		libxml2-dev \
		# mod_lua
		lua-dev \
		make \
		# mod_http2
		nghttp2-dev \
		# mod_session_crypto
		openssl \
		openssl-dev \
		pcre-dev \
		tar \
		# mod_deflate
		zlib-dev \
		brotli-dev \
	; \
	\
	ddist() { \
		local f="$1"; shift; \
		local distFile="$1"; shift; \
		local success=; \
		local distUrl=; \
		for distUrl in $APACHE_DIST_URLS; do \
			if wget -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
				success=1; \
				break; \
			fi; \
		done; \
		[ -n "$success" ]; \
	}; \
	\
	ddist 'httpd.tar.bz2' "httpd/httpd-$HTTPD_VERSION.tar.bz2"; \
	echo "$HTTPD_SHA256 *httpd.tar.bz2" | sha256sum -c -; \
	\
	ddist 'httpd.tar.bz2.asc' "httpd/httpd-$HTTPD_VERSION.tar.bz2.asc";
RUN export GNUPGHOME="$(mktemp -d)"; \
	for key in \
		DE29FB3971E71543FD2DC049508EAEC5302DA568 \
# Rodent of Unusual Size <coar@ACM.Org>
		13155B0E9E634F42BF6C163FDDBA64BA2C312D2F \
# Jim Jagielski <jim@apache.org>
		8B39757B1D8A994DF2433ED58B3A601F08C975E5 \
# Dean Gaudet <dgaudet@apache.org>
		31EE1A81B8D066548156D37B7D6DBFD1F08E012A \
# Cliff Woolley <jwoolley@apache.org>
		A10208FEC3152DD7C0C9B59B361522D782AB7BD1 \
# Cliff Woolley <jwoolley@virginia.edu>
		3DE024AFDA7A4B15CB6C14410F81AA8AB0D5F771 \
# Graham Leggett <minfrin@apache.org>
		EB138C6AF0FC691001B16D93344A844D751D7F27 \
# Roy T. Fielding <fielding@gbiv.com>
		CBA5A7C21EC143314C41393E5B968010E04F9A89 \
# Justin R. Erenkrantz <jerenkrantz@apache.org>
		3C016F2B764621BB549C66B516A96495E2226795 \
# Aaron Bannert <abannert@kuci.org>
		937FB3994A242BA9BF49E93021454AF0CC8B0F7E \
# Brad Nicholes <bnicholes@novell.com>
		EAD1359A4C0F2D37472AAF28F55DF0293A4E7AC9 \
# Sander Striker <striker@apache.org>
		4C1EADADB4EF5007579C919C6635B6C0DE885DD3 \
# Greg Stein <gstein@lyra.org>
		01E475360FCCF1D0F24B9D145D414AE1E005C9CB \
# Andre Malo <nd@apache.org>
		92CCEF0AA7DD46AC3A0F498BCA6939748103A37E \
# Erik Abele <erik@codefaktor.de>
		D395C7573A68B9796D38C258153FA0CD75A67692 \
# Astrid Kessler (Kess) <kess@kess-net.de>
		FA39B617B61493FD283503E7EED1EA392261D073 \
# Joe Schaefer <joe@sunstarsys.com>
		984FB3350C1D5C7A3282255BB31B213D208F5064 \
# Stas Bekman <stas@stason.org>
		FE7A49DAA875E890B4167F76CCB2EB46E76CF6D0 \
# Paul Querna <chip@force-elite.com>
		39F6691A0ECF0C50E8BB849CF78875F642721F00 \
# Colm MacCarthaigh <colm.maccarthaigh@heanet.ie>
		29A2BA848177B73878277FA475CAA2A3F39B3750 \
# Ruediger Pluem <rpluem@apache.org>
		120A8667241AEDD4A78B46104C042818311A3DE5 \
# Nick Kew <nick@webthing.com>
		453510BDA6C5855624E009236D0BC73A40581837 \
# Philip M. Gollucci <pgollucci@p6m7g8.com>
		0DE5C55C6BF3B2352DABB89E13249B4FEC88A0BF \
# Bojan Smojver <bojan@rexursive.com>
		7CDBED100806552182F98844E8E7E00B4DAA1988 \
# Issac Goldstand <margol@beamartyr.net>
		A8BA9617EF3BCCAC3B29B869EDB105896F9522D8 \
# "Guenter Knauf" ("CODE SIGNING KEY") <fuankg@apache.org>
		3E6AC004854F3A7F03566B592FF06894E55B0D0E \
# Jeff Trawick (CODE SIGNING KEY) <trawick@apache.org>
		5B5181C2C0AB13E59DA3F7A3EC582EB639FF092C \
# Jim Jagielski (Release Signing Key) <jim@apache.org>
		A93D62ECC3C8EA12DB220EC934EA76E6791485A8 \
# Eric Covener <covener@apache.org>
		65B2D44FE74BD5E3DE3AC3F082781DE46D5954FA \
# Yann Ylavic <ylavic@apache.org>
		8935926745E1CE7E3ED748F6EC99EE267EB5F61A \
# Daniel Ruggeri (http\x3a//home.apache.org/~druggeri/) <druggeri@apache.org>
		E3480043595621FE56105F112AB12A7ADC55C003 \
# Joe Orton (Release Signing Key) <jorton@apache.org>
		93525CFCF6FDFFB3FD9700DD5A4B10AE43B56A27 \
# Christophe JAILLET <christophe.jaillet@wanadoo.fr>
		C55AB7B9139EB2263CD1AABC19B033D1760C227B \	
	; do \
		gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	done; \
	gpg --batch --verify httpd.tar.bz2.asc httpd.tar.bz2; \
	command -v gpgconf && gpgconf --kill all || :; \
	rm -rf "$GNUPGHOME" httpd.tar.bz2.asc; \
	\
	mkdir -p src; \
	tar -xf httpd.tar.bz2 -C src --strip-components=1; \
	rm httpd.tar.bz2; \
	cd src; \
	wget -O ./build/config.sub "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD"; \
	wget -O ./build/config.guess "git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"; \
	\
	patches() { \
		while [ "$#" -gt 0 ]; do \
			local patchFile="$1"; shift; \
			local patchSha256="$1"; shift; \
			ddist "$patchFile" "httpd/patches/apply_to_$HTTPD_VERSION/$patchFile"; \
			echo "$patchSha256 *$patchFile" | sha256sum -c -; \
			patch -p0 < "$patchFile"; \
			rm -f "$patchFile"; \
		done; \
	}; \
	patches $HTTPD_PATCHES; \
	\
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--prefix="$HTTPD_PREFIX" \
		--enable-mods-shared=reallyall \
		--enable-mpms-shared=all \
	; \
	make -j "$(nproc)"; \
	make install; \
	\
	cd ..; \
	rm -r src man manual; \
	\
	sed -ri \
		-e 's!^(\s*CustomLog)\s+\S+!\1 /proc/self/fd/1!g' \
		-e 's!^(\s*ErrorLog)\s+\S+!\1 /proc/self/fd/2!g' \
		-e 's!^(\s*TransferLog)\s+\S+!\1 /proc/self/fd/1!g' \
		"$HTTPD_PREFIX/conf/httpd.conf" \
		"$HTTPD_PREFIX/conf/extra/httpd-ssl.conf" \
	; \
	\
	runDeps="$runDeps $( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --virtual .httpd-rundeps $runDeps; \
	apk del .build-deps; \
	\
	httpd -v
 
COPY httpd-foreground /usr/local/bin/
 
EXPOSE 80
CMD ["httpd-foreground"]
