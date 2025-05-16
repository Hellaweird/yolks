FROM eclipse-temurin:21-jdk-alpine

# Install required tools
RUN apk add --no-cache git maven curl bash

# Set working directory
WORKDIR /server

# Copy the entrypoint script
COPY entrypoint.sh /server/entrypoint.sh
RUN chmod +x /server/entrypoint.sh

# Default JAR file location (can be overridden)
ENV JAR_FILE=target/*.jar
ENV JAVA_OPTS=""

# Entrypoint
ENTRYPOINT ["/server/entrypoint.sh"]