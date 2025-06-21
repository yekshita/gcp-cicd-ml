# Docker Hub to Cloud Run Deployment

This folder contains everything you need to deploy existing Docker images from Docker Hub to Google Cloud Run using Cloud Build.

## 📁 Project Structure

```
ml-app/
├── cloudbuild.yaml          # Production deployment config
├── cloudbuild-dockerhub-staging.yaml  # Staging deployment config
└── README.md                          # This file
```

## 🚀 Quick Start

## 🛠️ Prerequisites

1. **Google Cloud Project** with billing enabled
2. **Required APIs enabled**:
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```



