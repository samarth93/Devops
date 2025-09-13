#!/usr/bin/env bash
set -euo pipefail

JENKINS_URL=${JENKINS_URL:-http://localhost:8080}
JENKINS_USER=${JENKINS_USER:-}
JENKINS_TOKEN=${JENKINS_TOKEN:-}
PLUGINS_FILE=${PLUGINS_FILE:-jenkins/plugins.txt}

if ! command -v curl >/dev/null 2>&1; then echo "curl is required"; exit 1; fi

if [ -z "${JENKINS_USER}" ] || [ -z "${JENKINS_TOKEN}" ]; then
  echo "Set JENKINS_USER and JENKINS_TOKEN env vars (Manage User > Configure > API Token)."
  exit 1
fi

CLI_JAR=jenkins/jenkins-cli.jar
mkdir -p jenkins
if [ ! -f "$CLI_JAR" ]; then
  echo "Downloading Jenkins CLI from $JENKINS_URL..."
  curl -fsSL "$JENKINS_URL/jnlpJars/jenkins-cli.jar" -o "$CLI_JAR"
fi

# Install each plugin
while IFS= read -r plugin || [ -n "$plugin" ]; do
  [ -z "$plugin" ] && continue
  echo "Installing plugin: $plugin"
  java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" install-plugin "$plugin" -deploy || {
    echo "Failed to install $plugin"; exit 1;
  }
  sleep 1

done < "$PLUGINS_FILE"

echo "Restarting Jenkins to apply plugins..."
java -jar "$CLI_JAR" -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_TOKEN" safe-restart

echo "Plugins installation requested. Jenkins will restart."