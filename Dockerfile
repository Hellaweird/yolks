FROM eclipse-temurin:21-jdk-alpine

# Install required tools
RUN apk add --no-cache git maven curl bash

# Set working directory to a writable location
WORKDIR /home/container

# Create a non-root user to avoid permission issues
RUN adduser -D -h /home/container container

# Copy the entrypoint script
COPY entrypoint.sh /home/container/entrypoint.sh
RUN chmod +x /home/container/entrypoint.sh && \
    chown container:container /home/container/entrypoint.sh

# User to run as
USER container

# Default JAR file location (can be overridden)
ENV JAR_FILE=target/*.jar
ENV JAVA_OPTS=""
ENV HOME=/home/container

# Entrypoint
ENTRYPOINT ["/home/container/entrypoint.sh"]