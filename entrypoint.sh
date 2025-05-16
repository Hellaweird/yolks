#!/bin/bash

echo "Starting server setup..."
cd /home/container

# Create a directory for Git config files
mkdir -p /home/container/.config/git
export GIT_CONFIG_GLOBAL=/home/container/.config/git/config

# Check if all required environment variables are set
if [ -z "$GIT_URL" ]; then
  echo "ERROR: GIT_URL environment variable is not set"
  exit 1
fi

# Clone repository with authentication if provided
echo "Cloning repository from $GIT_URL, branch: ${GIT_BRANCH:-main}"

if [ -n "$GIT_TOKEN" ] && [ -n "$GIT_USERNAME" ]; then
  # Extract domain from Git URL
  DOMAIN=$(echo $GIT_URL | sed -E 's/^https?:\/\/([^\/]+).*/\1/')
  
  # Configure git credentials in a writable location
  git config --global credential.helper 'store --file=/home/container/.git-credentials'
  echo "https://${GIT_USERNAME}:${GIT_TOKEN}@${DOMAIN}" > /home/container/.git-credentials
  chmod 600 /home/container/.git-credentials
fi

# Remove old source if it exists
if [ -d "/home/container/source" ]; then
  rm -rf /home/container/source
fi

# Clone the repository
echo "Creating source directory in /home/container"
mkdir -p /home/container/source

if [ -n "$GIT_BRANCH" ]; then
  git clone --single-branch --branch "$GIT_BRANCH" "$GIT_URL" /home/container/source
else
  git clone "$GIT_URL" /home/container/source
fi

# Check if clone was successful
if [ ! "$(ls -A /home/container/source 2>/dev/null)" ]; then
  echo "ERROR: Failed to clone the repository"
  echo "Current directory: $(pwd)"
  echo "Listing current directory: $(ls -la)"
  echo "HOME: $HOME"
  echo "Checking permissions: $(ls -la /home/container)"
  exit 1
fi

# Navigate to source directory
cd /home/container/source

# Build with Maven
echo "Building project with Maven..."
mvn clean package

# Find the JAR file to run
if [ -z "$(ls -A $JAR_FILE 2>/dev/null)" ]; then
  echo "ERROR: No JAR file found at $JAR_FILE"
  exit 1
fi

# Get the JAR file path
JAR_PATH=$(ls $JAR_FILE | head -n 1)
echo "Found JAR: $JAR_PATH"

# Run the application
echo "Starting application..."
exec java $JAVA_OPTS -jar $JAR_PATH