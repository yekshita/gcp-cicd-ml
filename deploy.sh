#!/bin/bash

# Docker Hub to Cloud Run Deployment Script
# This script reads the configuration and deploys your Docker Hub image to Cloud Run

set -e

echo "🚀 Docker Hub to Cloud Run Deployment Script"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first:"
    echo "   https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
    echo "❌ You are not authenticated with gcloud. Please run:"
    echo "   gcloud auth login"
    exit 1
fi

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project is set. Please set a project:"
    echo "   gcloud config set project YOUR_PROJECT_ID"
    exit 1
fi

echo "✅ Using project: $PROJECT_ID"

# Check if deploy-config.yaml exists
if [ ! -f "deploy-config.yaml" ]; then
    echo "❌ deploy-config.yaml not found. Please create it first."
    exit 1
fi

# Parse configuration (simple YAML parsing)
DOCKER_IMAGE=$(grep "docker_image:" deploy-config.yaml | cut -d'"' -f2)
SERVICE_NAME=$(grep "service_name:" deploy-config.yaml | cut -d'"' -f2)
REGION=$(grep "region:" deploy-config.yaml | cut -d'"' -f2)
PORT=$(grep "port:" deploy-config.yaml | cut -d'"' -f2)
MEMORY=$(grep "memory:" deploy-config.yaml | cut -d'"' -f2)
CPU=$(grep "cpu:" deploy-config.yaml | cut -d'"' -f2)

# Validate required values
if [ -z "$DOCKER_IMAGE" ] || [ "$DOCKER_IMAGE" = "your-dockerhub-username/your-image:latest" ]; then
    echo "❌ Please update docker_image in deploy-config.yaml"
    exit 1
fi

echo "📋 Deployment Configuration:"
echo "   Docker Image: $DOCKER_IMAGE"
echo "   Service Name: $SERVICE_NAME"
echo "   Region: $REGION"
echo "   Port: $PORT"
echo "   Memory: $MEMORY"
echo "   CPU: $CPU"

# Ask for confirmation
read -p "🤔 Do you want to proceed with deployment? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

# Determine environment
ENVIRONMENT=${1:-production}
if [ "$ENVIRONMENT" = "staging" ]; then
    CONFIG_FILE="cloudbuild-dockerhub-staging.yaml"
    echo "🎯 Deploying to STAGING environment"
else
    CONFIG_FILE="cloudbuild-dockerhub.yaml"
    echo "🎯 Deploying to PRODUCTION environment"
fi

# Trigger Cloud Build with substitutions
echo "🚀 Triggering Cloud Build deployment..."
gcloud builds submit \
    --config="$CONFIG_FILE" \
    --substitutions=_DOCKER_IMAGE="$DOCKER_IMAGE",_SERVICE_NAME="$SERVICE_NAME",_REGION="$REGION",_PORT="$PORT",_MEMORY="$MEMORY",_CPU="$CPU"

echo "✅ Deployment triggered successfully!"
echo ""
echo "📊 Monitor your deployment:"
echo "   https://console.cloud.google.com/cloud-build/builds"
echo ""
echo "🌐 Your service will be available at:"
echo "   https://$SERVICE_NAME-$PROJECT_ID.$REGION.run.app" 