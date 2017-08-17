FROM kriation/centos7-jre8 as spigot-builder
ARG SPIGOT_VERSION
ENV SPIGOT_VERSION ${SPIGOT_VERSION:-latest}
WORKDIR /tmp/spigot
RUN yum install git && \
	curl -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar && \
	java -jar BuildTools.jar -rev $SPIGOT_VERSION

FROM kriation/centos7-jre8
WORKDIR /opt/spigot
COPY --from=spigot-builder /tmp/spigot/spigot*.jar .
RUN useradd -d /opt/spigot -M -U spigot && \
	chown -R spigot:spigot /opt/spigot
USER spigot
