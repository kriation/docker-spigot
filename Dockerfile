FROM kriation/centos7-jre8 as spigot-builder
ARG SPIGOT_VERSION=latest
ENV SPIGOT_VERSION ${SPIGOT_VERSION:-latest}
WORKDIR /tmp/spigot
RUN yum install git && \
	curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
	java -jar BuildTools.jar -rev $SPIGOT_VERSION

FROM kriation/centos7-jre8 as spigot-config
ARG SPIGOT_VERSION=latest
ENV SPIGOT_VERSION ${SPIGOT_VERSION:-latest}
WORKDIR /opt/spigot
COPY --from=spigot-builder /tmp/spigot/spigot*.jar spigot-$SPIGOT_VERSION.jar
COPY config/* /opt/spigot/
RUN useradd -d /opt/spigot -M -U spigot && \
	mkdir -p /opt/spigot/{logs,plugins,worlds} && \
	chown -R spigot:spigot /opt/spigot
USER spigot
ARG MC_EULA=false
ENV MC_EULA ${MC_EULA:-false}
RUN echo eula=$MC_EULA >> eula.txt
ARG MC_SERVER_MEM=1024M
ENV MC_SERVER_MEM ${MC_SERVER_MEM:-1024M}
ARG MC_SERVER_PORT=25565
ENV MC_SERVER_PORT ${MC_SERVER_PORT:-25565}
ARG MC_SERVER_QUERY=false
ENV MC_SERVER_QUERY ${MC_SERVER_QUERY:-false}
ARG MC_SERVER_QUERY_PORT=25565
ENV MC_SERVER_QUERY_PORT ${MC_SERVER_QUERY_PORT:-25565}
ARG MC_SERVER_RCON=false
ENV MC_SERVER_RCON ${MC_SERVER_RCON:-false}
ARG MC_SERVER_RCON_PORT=25567
ENV MC_SERVER_RCON_PORT ${MC_SERVER_RCON_PORT:-25567}
ARG MC_SERVER_RCON_PASS
ENV MC_SERVER_RCON_PASS ${MC_SERVER_RCON_PASS}
VOLUME /opt/spigot/logs /opt/spigot/plugins /opt/spigot/worlds
