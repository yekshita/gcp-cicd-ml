#!/bin/bash

# Quick Docker Hub to Cloud Run Deployment
# Usage: ./quick-deploy.sh <docker-image> [service-name] [region]

set -e

# Check if Docker image is provided
if [ -z "$1" ]; then
    echo "❌ Usage: $0 <docker-image> [service-name] [region]"
    echo "   Example: $0 nginx:latest my-nginx us-central1"
    exit 1
fi

DOCKER_IMAGE=$1
SERVICE_NAME=${2:-"dockerhub-app"}
REGION=${3:-"us-central1"}

echo "🚀 Quick Docker Hub to Cloud Run Deployment"
echo "   Docker Image: $DOCKER_IMAGE"
echo "   Service Name: $SERVICE_NAME"
echo "   Region: $REGION"

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed"
    exit 1
fi

# Get project ID
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
    echo "❌ No project is set"
    exit 1
fi

echo "✅ Using project: $PROJECT_ID"

# Create temporary Cloud Build config
TEMP_CONFIG=$(mktemp)
cat > "$TEMP_CONFIG" << EOF
steps:
  # Pull the Docker image from Docker Hub
  - name: 'gcr.io/cloud-builders/docker'
    args: ['pull', '$DOCKER_IMAGE']
  
  # Tag the image for Google Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['tag', '$DOCKER_IMAGE', 'gcr.io/$PROJECT_ID/$SERVICE_NAME:latest']
  
  # Push the image to Google Container Registry
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/$SERVICE_NAME:latest']
  
  # Deploy to Cloud Run
  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - 'run'
      - 'deploy'
      - '$SERVICE_NAME'
      - '--image'
      - 'gcr.io/$PROJECT_ID/$SERVICE_NAME:latest'
      - '--region'
      - '$REGION'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
      - '--port'
      - '8080'

images:
  - 'gcr.io/$PROJECT_ID/$SERVICE_NAME:latest'

timeout: '1200s'

options:
  logging: CLOUD_LOGGING_ONLY
EOF

# Trigger deployment
echo "🚀 Deploying..."
gcloud builds submit --config="$TEMP_CONFIG"

# Clean up
rm "$TEMP_CONFIG"

echo "✅ Deployment completed!"
echo "🌐 Your service is available at:"
echo "   https://$SERVICE_NAME-$PROJECT_ID.$REGION.run.app" 