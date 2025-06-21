# Docker Hub to Cloud Run Deployment

This folder contains everything you need to deploy existing Docker images from Docker Hub to Google Cloud Run using Cloud Build.

## 📁 Project Structure

```
dockerhub-deploy/
├── cloudbuild-dockerhub.yaml          # Production deployment config
├── cloudbuild-dockerhub-staging.yaml  # Staging deployment config
├── deploy-config.yaml                 # Configuration file
├── deploy.sh                          # Main deployment script
├── quick-deploy.sh                    # Quick deployment script
└── README.md                          # This file
```

## 🚀 Quick Start

### Option 1: Quick Deployment (Recommended for testing)

```bash
# Make scripts executable
chmod +x *.sh

# Deploy any Docker Hub image quickly
./quick-deploy.sh nginx:latest my-nginx us-central1
```

### Option 2: Configured Deployment (Recommended for production)

1. **Update the configuration**:
   ```bash
   # Edit deploy-config.yaml
   nano deploy-config.yaml
   ```

2. **Update these values**:
   ```yaml
   docker_image: "your-dockerhub-username/your-image:latest"
   service_name: "your-app-name"
   region: "us-central1"
   ```

3. **Deploy**:
   ```bash
   # Deploy to production
   ./deploy.sh

   # Deploy to staging
   ./deploy.sh staging
   ```

## 📋 Configuration Options

### `deploy-config.yaml`

```yaml
# Docker Hub Image Configuration
docker_image: "your-dockerhub-username/your-image:latest"

# Cloud Run Service Configuration
service_name: "dockerhub-app"
region: "us-central1"
port: "8080"

# Resource Configuration
memory: "512Mi"
cpu: "1"

# Environment Variables (optional)
environment_variables:
  - "ENVIRONMENT=production"
  - "NODE_ENV=production"

# Scaling Configuration (optional)
min_instances: "0"
max_instances: "10"
```

## 🔧 Usage Examples

### Deploy a Web Application

```bash
# Update config
docker_image: "myusername/mywebapp:latest"
service_name: "mywebapp"
port: "3000"

# Deploy
./deploy.sh
```

### Deploy a Database

```bash
# Update config
docker_image: "postgres:13"
service_name: "my-database"
port: "5432"

# Deploy
./deploy.sh
```

### Deploy Multiple Services

```bash
# Service 1
./quick-deploy.sh nginx:latest frontend us-central1

# Service 2
./quick-deploy.sh redis:6 backend-cache us-central1

# Service 3
./quick-deploy.sh mysql:8 database us-central1
```

## 🛠️ Prerequisites

1. **Google Cloud Project** with billing enabled
2. **Required APIs enabled**:
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   gcloud services enable containerregistry.googleapis.com
   ```

3. **IAM Permissions** for Cloud Build service account:
   ```bash
   # Run the setup script from the parent directory
   cd ..
   ./setup.sh
   ```

## 📊 Monitoring

### View Build Logs
```bash
gcloud builds list
gcloud builds log [BUILD_ID]
```

### View Service Status
```bash
gcloud run services list
gcloud run services describe [SERVICE_NAME] --region=[REGION]
```

### View Service Logs
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=[SERVICE_NAME]" --limit=50
```

## 🔒 Security Considerations

### Private Docker Hub Images

If your Docker image is private, you'll need to configure Docker Hub authentication:

1. **Create a Docker Hub access token**
2. **Store it in Secret Manager**:
   ```bash
   echo -n "your-dockerhub-token" | gcloud secrets create dockerhub-token --data-file=-
   ```

3. **Update Cloud Build config** to use the secret:
   ```yaml
   steps:
     - name: 'gcr.io/cloud-builders/docker'
       args: ['login', '-u', 'your-username', '-p', '$$DOCKERHUB_TOKEN']
       secretEnv: ['DOCKERHUB_TOKEN']
   
   availableSecrets:
     secretManager:
       - versionName: projects/$PROJECT_ID/secrets/dockerhub-token/versions/latest
         env: 'DOCKERHUB_TOKEN'
   ```

### Network Security

- **VPC Connector**: For private network access
- **Cloud Armor**: For DDoS protection
- **Identity-Aware Proxy**: For authentication

## 💰 Cost Optimization

1. **Set appropriate resource limits**:
   ```yaml
   memory: "256Mi"  # Start small
   cpu: "0.5"       # Use fractional CPUs
   ```

2. **Configure scaling**:
   ```yaml
   min_instances: "0"  # Scale to zero
   max_instances: "5"  # Limit maximum instances
   ```

3. **Use appropriate regions** for your users

## 🚨 Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   # Run setup script
   cd ..
   ./setup.sh
   ```

2. **Image Pull Failed**:
   - Check if the Docker image exists
   - Verify image name and tag
   - For private images, configure authentication

3. **Service Not Accessible**:
   ```bash
   # Check service status
   gcloud run services describe [SERVICE_NAME] --region=[REGION]
   
   # Check IAM policy
   gcloud run services get-iam-policy [SERVICE_NAME] --region=[REGION]
   ```

### Debug Commands

```bash
# Check build status
gcloud builds list --limit=5

# View detailed build logs
gcloud builds log [BUILD_ID]

# Check service configuration
gcloud run services describe [SERVICE_NAME] --region=[REGION]

# Test service health
curl https://[SERVICE_NAME]-[PROJECT_ID].[REGION].run.app/health
```

## 📚 Additional Resources

- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Docker Hub Documentation](https://docs.docker.com/docker-hub/)
- [Google Cloud Pricing](https://cloud.google.com/pricing)

## 🤝 Support

For issues and questions:
- Check the troubleshooting section above
- Review Cloud Build and Cloud Run logs
- Consult the Google Cloud documentation 