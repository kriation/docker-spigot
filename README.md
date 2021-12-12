# Spigot Minecraft Server on CentOS v7
This set facilitates the assembly of an image that contains a version of Spigot specified at build time. The Dockerfile contains a two stage build (uses [multi-stage](https://docs.docker.com/engine/userguide/eng-image/multistage-build/)).
The image is derived by an existing CentOS v7 image with Oracle JRE v8.
The first build step uses a Docker build arg to define which version of Spigot to build. Once complete, the second build step copies the resulting JAR and processes the Spigot server configuration based on other build args. In addition, it copies the following configuration files to the runtime directory:

* banned-ips.json
* banned-players.json
* bukkit.yml
* commands.yml
* help.yml
* ops.json
* permissions.yml
* server.properties
* spigot.yml
* usercache.json
* whitelist.json

The final build image exposes the following components:

* Port
	* Server
	* Query
	* RCON
* Volumes	
	* /opt/spigot/logs
	* /opt/spigot/plugins
	* /opt/spigot/worlds

The volumes provide the ability to externally manage log content, plugins, and world data outside the scope of the container.

At runtime, the image uses a minimum JVM heap size of 1024M, the Garbage First Garbage Collector (as it's a low pause, server-style GC), and the '--noconsole' Spigot argument to notify the server that console input will not be expected.

The arguments (and their default values) that can be passed at build time of the image are:
* SPIGOT_VERSION=latest
* MC_EULA=false
* MC_SERVER_MEM=1024M
* MC_SERVER_PORT=25565
* MC_SERVER_QUERY=false
* MC_SERVER_QUERY_PORT=25565
* MC_SERVER_RCON=false
* MC_SERVER_RCON_PORT=25567
* MC_SERVER_RCON_PASS

Once the image is built, the above values **cannot** be changed at instantiation of the container via environment variables passed at runtime. This intentional design forces the image to be used as part of a continuous integration and continuous deployment (CI/CD) process.
