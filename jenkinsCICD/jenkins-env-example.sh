#!/bin/bash
# Example environment variables for Jenkins configuration
# Copy this file to jenkins-env.sh and update with your values
# Then source it: source jenkins-env.sh

# Docker Registry Configuration
export DOCKER_USERNAME="your-docker-username"
export DOCKER_PASSWORD="your-docker-token"
export DOCKER_REGISTRY="docker.io"

# GitHub Configuration
export GITHUB_TOKEN="your-github-personal-access-token"
export GITHUB_REPO="https://github.com/your-org/your-repo.git"
export GITHUB_BRANCH="main"

# AWS Configuration
export AWS_REGION="ap-south-2"
export AWS_ACCOUNT_ID="your-aws-account-id"
export AWS_ACCESS_KEY_ID="your-aws-access-key"
export AWS_SECRET_ACCESS_KEY="your-aws-secret-key"

# Kubernetes Configuration
export KUBECONFIG="/var/lib/jenkins/.kube/config"
export K8S_CLUSTER_NAME="my-eks-cluster"
export K8S_NAMESPACE="default"

# Jenkins Configuration
export JENKINS_URL="http://localhost:8080"
export JENKINS_USER="admin"
export JENKINS_TOKEN="your-jenkins-api-token"

# Service Configuration
export SERVICE_NAME="recommendation"
export SERVICE_PATH="src/recommendation"
export K8S_MANIFEST_PATH="kubernetes/recommendation/deploy.yaml"

# Git Configuration
export GIT_AUTHOR_EMAIL="jenkins@example.com"
export GIT_AUTHOR_NAME="Jenkins CI"

# Build Configuration
export BUILD_TIMEOUT="30"  # minutes
export DOCKER_BUILD_CONTEXT="src/recommendation"
export DOCKERFILE_PATH="src/recommendation/Dockerfile"

# Notification Configuration
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
export SLACK_CHANNEL="#ci-cd"
export EMAIL_RECIPIENTS="devops@example.com"

# Feature Flags
export ENABLE_SLACK_NOTIFICATIONS="true"
export ENABLE_EMAIL_NOTIFICATIONS="false"
export ENABLE_GITHUB_CHECKS="true"
export ENABLE_AUTO_DEPLOY="true"

# Logging Configuration
export LOG_LEVEL="INFO"
export JENKINS_LOG_FILE="/var/log/jenkins/jenkins.log"

# Performance Configuration
export JENKINS_JAVA_OPTS="-Xmx2g -Xms2g"
export DOCKER_BUILD_PARALLEL="true"
export TEST_PARALLEL_JOBS="4"

# Security Configuration
export ENABLE_HTTPS="false"
export SSL_CERT_PATH="/etc/jenkins/ssl/cert.pem"
export SSL_KEY_PATH="/etc/jenkins/ssl/key.pem"

# Artifact Configuration
export ARTIFACT_RETENTION_DAYS="30"
export ARTIFACT_STORAGE_PATH="/var/lib/jenkins/artifacts"

# Backup Configuration
export BACKUP_ENABLED="true"
export BACKUP_SCHEDULE="0 2 * * *"  # 2 AM daily
export BACKUP_RETENTION_DAYS="7"
export BACKUP_STORAGE_PATH="/backups/jenkins"

echo "Jenkins environment variables loaded!"
echo "Service: $SERVICE_NAME"
echo "Cluster: $K8S_CLUSTER_NAME"
echo "Docker Registry: $DOCKER_REGISTRY"
