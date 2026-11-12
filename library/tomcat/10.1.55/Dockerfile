#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM cr.loongnix.cn/library/openjdk:11-buster
MAINTAINER Xuhui Qiang <qiangxuhui@loongson.cn>

ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# let "Tomcat Native" live somewhere isolated
ENV TOMCAT_NATIVE_LIBDIR $CATALINA_HOME/native-jni-lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$TOMCAT_NATIVE_LIBDIR

# see https://www.apache.org/dist/tomcat/tomcat-9/KEYS
# see also "versions.sh" (https://github.com/docker-library/tomcat/blob/master/versions.sh)
ENV GPG_KEYS 48F8E69F6390C9F25CFEDCD268248959359E722B A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 DCFD35E0BF8CA7344752DE8B6FB21E8933C60243

ENV TOMCAT_MAJOR 10
ENV TOMCAT_VERSION 10.1.55
ENV TOMCAT_SHA512 f36af12391a277e5c3a802a8e1a2a1e4354cd461b547d2e1a33ac0ab88d707d3fb2591e034a17b7d3a6b965a4c977a97dbf29bb81a3867e85aeec3d8d189e22e

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		dirmngr \
		gnupg \
	; \
	\
	ddist() { \
		local f="$1"; shift; \
		local distFile="$1"; shift; \
		local mvnFile="${1:-}"; \
		local success=; \
		local distUrl=; \
		for distUrl in \
			"https://www.apache.org/dyn/closer.cgi?action=download&filename=$distFile" \
			"https://downloads.apache.org/$distFile" \
			"https://www-us.apache.org/dist/$distFile" \
			"https://www.apache.org/dist/$distFile" \
			"https://archive.apache.org/dist/$distFile" \
			${mvnFile:+"https://repo1.maven.org/maven2/org/apache/tomcat/tomcat/$mvnFile"} \
		; do \
			if curl -fL -o "$f" "$distUrl" && [ -s "$f" ]; then \
				success=1; \
				break; \
			fi; \
		done; \
		[ -n "$success" ]; \
	}; \
	\
	ddist 'tomcat.tar.gz' "tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz" "$TOMCAT_VERSION/tomcat-$TOMCAT_VERSION.tar.gz"; \
	ddist 'tomcat.tar.gz.asc' "tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz.asc" "$TOMCAT_VERSION/tomcat-$TOMCAT_VERSION.tar.gz.asc"; \
	tar -xf tomcat.tar.gz --strip-components=1; \
	rm bin/*.bat; \
	rm tomcat.tar.gz*; \
	command -v gpgconf && gpgconf --kill all || :; \
	\
	mv webapps webapps.dist; \
	mkdir webapps; \
	\
	apt-get install -y --no-install-recommends \
		dpkg-dev \
		gcc \
		libc6-dev \
		libssl-dev \
		make \
	; \
	\
	nproc="$(nproc)"; \
	\
	aprVersion=1.7.6; \
	aprBuildDir="$(mktemp -d)"; \
	curl -fL -o "$aprBuildDir/apr.tar.gz" "https://archive.apache.org/dist/apr/apr-${aprVersion}.tar.gz"; \
	tar -xf "$aprBuildDir/apr.tar.gz" -C "$aprBuildDir" --strip-components=1; \
	( \
		cd "$aprBuildDir"; \
		./configure --prefix=/usr/local/apr --disable-static; \
		make -j "$nproc"; \
		make install; \
	); \
	echo "/usr/local/apr/lib" > /etc/ld.so.conf.d/apr.conf; \
	ldconfig; \
	rm -rf "$aprBuildDir"; \
	\
	tcnativeVersion=1.3.7; \
	nativeBuildDir="$(mktemp -d)"; \
	curl -fL -o "$nativeBuildDir/tcnative.tar.gz" \
		"https://archive.apache.org/dist/tomcat/tomcat-connectors/native/${tcnativeVersion}/source/tomcat-native-${tcnativeVersion}-src.tar.gz"; \
	tar -xf "$nativeBuildDir/tcnative.tar.gz" -C "$nativeBuildDir" --strip-components=1; \
	( \
		export CATALINA_HOME="$PWD"; \
		cd "$nativeBuildDir/native"; \
		curl -fsSL -o build/config.guess 'https://git.savannah.gnu.org/cgit/config.git/plain/config.guess' && chmod +x build/config.guess; \
		curl -fsSL -o build/config.sub 'https://git.savannah.gnu.org/cgit/config.git/plain/config.sub' && chmod +x build/config.sub; \
		head -n 1 build/config.sub | grep -q '^#!' || { echo "config.sub 下载内容无效"; exit 1; }; \
		gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
		./configure \
			--build="$gnuArch" \
			--libdir="$TOMCAT_NATIVE_LIBDIR" \
			--prefix="$CATALINA_HOME" \
			--with-apr=/usr/local/apr/bin/apr-1-config \
			--with-java-home="$JAVA_HOME" \
			--with-ssl=/usr \
		; \
		make -j "$nproc"; \
		make install; \
	); \
	rm -rf "$nativeBuildDir"; \
	rm bin/tomcat-native.tar.gz; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark > /dev/null; \
	rm -rf /var/lib/apt/lists/*; \
	\
	find ./bin/ -name '*.sh' -exec sed -ri 's|^#!/bin/sh$|#!/usr/bin/env bash|' '{}' +; \
	\
	chmod -R +rX .; \
	chmod 777 logs temp work; \
	\
	catalina.sh version

# verify Tomcat Native is working properly
RUN set -eux; \
	nativeLines="$(catalina.sh configtest 2>&1)"; \
	nativeLines="$(echo "$nativeLines" | grep 'Apache Tomcat Native')"; \
	nativeLines="$(echo "$nativeLines" | sort -u)"; \
	if ! echo "$nativeLines" | grep -E 'INFO: Loaded( APR based)? Apache Tomcat Native library' >&2; then \
		echo >&2 "$nativeLines"; \
		exit 1; \
	fi

EXPOSE 8080
CMD ["catalina.sh", "run"]
