# ------------------------------------------------------------------------------
# Use the latest InterSystems IRIS Community Edition image as base
# ------------------------------------------------------------------------------
FROM intersystems/iris-community:latest-cd

# ------------------------------------------------------------------------------
# Work as root temporarily to create directories and adjust permissions
# ------------------------------------------------------------------------------
USER root

# Create the working directory inside the image for your application code
WORKDIR /opt/irisapp

# Ensure the irisowner user (default IRIS user) owns the workdir
RUN chown ${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} /opt/irisapp

# ------------------------------------------------------------------------------
# Copy in application source and scripts
# ------------------------------------------------------------------------------

# Your application classes 
COPY src src

# IRIS installer to create namespace and database
COPY Installer.cls .

# Script that will be executed by entrypoint at runtime to import source code 
COPY iris.script .

# Startup script wrapper (will run at *container start*)
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ------------------------------------------------------------------------------
# Switch back to the IRIS user (never run IRIS as root!)
# ------------------------------------------------------------------------------
USER ${ISC_PACKAGE_MGRUSER}

# ------------------------------------------------------------------------------
# About build-time imports:
#
# The following RUN command would import classes during *image build*:
#
# RUN iris start IRIS && \
#     iris session IRIS < /tmp/iris.script && \
#     iris stop IRIS quietly
#
# Why it doesn’t work when you mount a durable volume:
# - At build time, Dockerfile use RUN to start IRIS and loads your classes 
#   into the *internal image database* through iris.script.
# - But at runtime, your docker-compose.yml sets:
#       environment:
#         - ISC_DATA_DIRECTORY=/durable/iris
#       volumes:
#         - ./storage:/durable
#   This tells IRIS: “ignore the internal database and use /durable/iris instead”.
# - That durable directory starts empty unless you preload it.
# - Result: anything you imported at build time is invisible at runtime.
#
# --> **Solution**: keep imports in `entrypoint.sh`, so they happen every time
#    the container starts, against the *active durable database*.
#
# You can still use the RUN line if you want a *stateless* container
# (no durable volume) for quick tests.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Entrypoint: this runs your entrypoint.sh, which will start IRIS,
# import your code into the current USER namespace, and then hand over
# control to the default IRIS entrypoint.
# Logs can be found in /opt/irisapp/logs and in Docker Desktop either.
# ------------------------------------------------------------------------------
ENTRYPOINT ["/entrypoint.sh"]

# ------------------------------------------------------------------------------
# Ports
# 1972  -> IRIS SuperServer (ODBC, JDBC, etc.)
# 52773 -> Management Portal / Web Apps
# ------------------------------------------------------------------------------
EXPOSE 1972 52773
