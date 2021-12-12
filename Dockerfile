ARG JAVA_VERSION=17

FROM kriation/centos7-java:${JAVA_VERSION} as spigot-builder
ARG SPIGOT_VERSION=latest
ENV SPIGOT_VERSION ${SPIGOT_VERSION:-latest}
WORKDIR /tmp/spigot
RUN yum -y install git && \
	curl -o BuildTools.jar \
    https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
	java -jar BuildTools.jar -rev $SPIGOT_VERSION

FROM kriation/centos7-java:${JAVA_VERSION} as spigot-config
ARG SPIGOT_VERSION=latest
ARG MC_EULA=false
ARG MC_SERVER_MEM=1024M
ARG MC_SERVER_PORT=25565
ARG MC_SERVER_QUERY=false
ARG MC_SERVER_QUERY_PORT=25565
ARG MC_SERVER_RCON=false
ARG MC_SERVER_RCON_PORT=25567
ARG MC_SERVER_RCON_PASS
ARG JMX_ON=false
ARG JMX_PORT=9000
ENV SPIGOT_VERSION=${SPIGOT_VERSION:-latest} \
	MC_SERVER_MEM=${MC_SERVER_MEM:-1024M} \
	MC_SERVER_PORT=${MC_SERVER_PORT:-25565} \
	MC_SERVER_QUERY=${MC_SERVER_QUERY:-false} \
	MC_SERVER_QUERY_PORT=${MC_SERVER_QUERY_PORT:-25565} \
	MC_SERVER_RCON=${MC_SERVER_RCON:-false} \
	MC_SERVER_RCON_PORT=${MC_SERVER_RCON_PORT:-25567} \
	MC_SERVER_RCON_PASS=${MC_SERVER_RCON_PASS} \
	MC_EULA=${MC_EULA:-false} \
	JMX_ON=${JMX_ON:-false} \
	JMX_PORT=${JXM_PORT:-9000}
WORKDIR /opt/spigot
COPY --from=spigot-builder /tmp/spigot/spigot*.jar /tmp/spigot-$SPIGOT_VERSION.jar
COPY config/* /opt/spigot/
RUN useradd -d /opt/spigot -M -U spigot && \
	mkdir -p /opt/spigot/{logs,plugins,worlds} && \
	chown -R spigot:spigot /opt/spigot
USER spigot
RUN	sed -i 's/\(server-port=\)[[:print:]]*/\1'"$MC_SERVER_PORT"'/g' server.properties && \
	sed -i 's/\(enable-query=\)[[:print:]]*/\1'"$MC_SERVER_QUERY"'/g' server.properties && \
	sed -i 's/\(enable-rcon=\)[[:print:]]*/\1'"$MC_SERVER_RCON"'/g' server.properties && \
	sed -i 's/\(query.port=\)[[:print:]]*/\1'"$MC_SERVER_QUERY_PORT"'/g' server.properties && \
	sed -i 's/\(rcon.port=\)[[:print:]]*/\1'"$MC_SERVER_RCON_PORT"'/g' server.properties && \
	sed -i 's/\(rcon.password=\)[[:print:]]*/\1'"$MC_SERVER_RCON_PASS"'/g' server.properties
EXPOSE $MC_SERVER_PORT $MC_SERVER_QUERY_PORT $MC_SERVER_RCON_PORT $JMX_PORT
VOLUME /opt/spigot
ENTRYPOINT /usr/bin/java -Xms$MC_SERVER_MEM -Xmx$MC_SERVER_MEM -XX:+UseG1GC \
-Dlog4j2.formatMsgNoLookups=true \
-Dcom.sun.management.jmxremote=$JMX_ON \
-Dcom.sun.management.jmxremote.port=$JMX_PORT \
-Dcom.sun.management.jmxremote.local.only=false \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Dcom.mojang.eula.agree=$MC_EULA -jar /tmp/spigot-$SPIGOT_VERSION.jar --world-dir /opt/spigot/worlds --noconsole

FROM spigot-config

ARG BUILD_DATE
ARG SPIGOT_VERSION=latest
ENV SPIGOT_VERSION ${SPIGOT_VERSION:-latest}

LABEL maintainer="armen@kriation.com"
LABEL org.label-schema.build-date="$BUILD_DATE"
LABEL org.label-schema.license="GPLv2"
LABEL org.label-schema.name="Spigot Minecraft Server ($SPIGOT_VERSION) on CentOS v7"
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.vendor="armen@kriation.com"
LABEL org.opencontainers.image.created="$BUILD_DATE"
LABEL org.opencontainers.image.licenses="GPL-2.0-only"
LABEL org.opencontainers.image.title="Spigot Minecraft Server ($SPIGOT_VERSION) on CentOS v7"
LABEL org.opencontainers.image.vendor="armen@kriation.com"
