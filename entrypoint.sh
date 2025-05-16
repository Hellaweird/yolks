#!/bin/bash

echo "Starting server setup..."

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
  
  # Configure git credentials
  git config --global credential.helper store
  echo "https://${GIT_USERNAME}:${GIT_TOKEN}@${DOMAIN}" > ~/.git-credentials
  git config --global credential.helper 'store --file ~/.git-credentials'
  git config --global credential.helper cache
fi

# Remove old source if it exists
if [ -d "./source" ]; then
  rm -rf ./source
fi

# Clone the repository
if [ -n "$GIT_BRANCH" ]; then
  git clone --single-branch --branch "$GIT_BRANCH" "$GIT_URL" ./source
else
  git clone "$GIT_URL" ./source
fi

# Check if clone was successful
if [ ! -d "./source" ]; then
  echo "ERROR: Failed to clone the repository"
  exit 1
fi

# Navigate to source directory
cd ./source

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