### Rundeck source
FROM rundeck/rundeck:4.7.0 as rundeck

### Remco build
FROM --platform=$BUILDPLATFORM golang:1.19.3 as remco

RUN cd /go/src && \
	git clone https://github.com/HeavyHorst/remco.git && \
	cd remco && \
	make build

# My rundeck image
FROM --platform=$BUILDPLATFORM ubuntu:20.04

ARG TARGETOS TARGETPLATFORM TARGETARCH

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

# Update image apt packages
USER root

## BASH
RUN echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure dash

## General package configuration
RUN set -euxo pipefail \
    && apt-get -y update && apt-get upgrade -y && apt-get -y --no-install-recommends install \
        acl \
        curl \
        gnupg2 \
        ssh-client \
        sudo \
        openjdk-11-jdk-headless \
        uuid-runtime \
        wget \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/* \
    # Setup rundeck user
    && adduser --gid 0 --shell /bin/bash --home /home/rundeck --gecos "" --disabled-password rundeck \
    && chmod 0775 /home/rundeck \
    && passwd -d rundeck \
    && addgroup rundeck sudo \
    && chmod g+w /etc/passwd

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH} /tini-${TARGETARCH}
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TARGETARCH}.asc /tini-${TARGETARCH}.asc
RUN gpg --batch --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 595E85A6B1B4779EA4DAAEC70B588DFF0527A9B7 \
 && gpg --batch --verify /tini-${TARGETARCH}.asc /tini-${TARGETARCH}
RUN mv /tini-${TARGETARCH} /tini && chmod +x /tini

COPY --from=remco /go/src/remco/bin/remco /usr/local/bin/remco

USER rundeck

WORKDIR /home/rundeck

COPY --from=rundeck /etc/remco /etc/remco
COPY --from=rundeck /home/rundeck .

COPY --chown=rundeck:root remco /etc/remco
RUN mkdir tempo && \
	cd tempo && \
	jar -xf ../rundeck.war WEB-INF/rundeck/plugins/ && \
	zip -d ../rundeck.war WEB-INF/rundeck/plugins/\* && \
	cd WEB-INF/rundeck/plugins && \
	for f in *ansible* *aws* *azure* *py-winrm*; do test -f $f && rm $f; done && \
	echo '#generated manifest' > manifest.properties && \
	echo -n '# ' >> manifest.properties && \
	date >> manifest.properties && \
	echo -n 'pluginFileList=' >> manifest.properties && \
	ls *.jar *.zip | sort -u | xargs | sed 's/ /,/g' >> manifest.properties && \
	cd /home/rundeck/tempo/ && \
	jar -uf ../rundeck.war WEB-INF && \
	cd /home/rundeck && \
	rm -rf tempo && \
	mkdir .ssh
ADD --chown=rundeck:root https://github.com/rundeck-plugins/slack-incoming-webhook-plugin/releases/download/v1.2.5/slack-incoming-webhook-plugin-1.2.5.jar /home/rundeck/libext/

VOLUME ["/home/rundeck/server/data"]

EXPOSE 4440
ENTRYPOINT [ "/tini", "--", "docker-lib/entry.sh" ]
