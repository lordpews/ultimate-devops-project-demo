# Jenkins Configuration Guide

This guide covers configuring Jenkins after infrastructure deployment.

## Prerequisites

- Infrastructure deployed (see INFRASTRUCTURE_SETUP.md)
- Jenkins accessible at `http://jenkins.example.com:8080`
- Initial admin password obtained

## Step 1: Initial Setup

### Access Jenkins

1. Open browser: `http://jenkins.example.com:8080`
2. Enter initial admin password
3. Click **Continue**

### Install Plugins

1. Select **Install suggested plugins**
2. Wait for installation to complete
3. Create first admin user

### Configure System

1. Go to **Manage Jenkins** → **Configure System**
2. Set Jenkins URL: `http://jenkins.example.com:8080/`
3. Configure email notifications (optional)
4. Click **Save**

## Step 2: Add Credentials

### Docker Registry Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **Add Credentials**
3. Create credentials:
   - **Kind**: Username with password
   - **Username**: `docker-username` (your Docker Hub username)
   - **Password**: Your Docker Hub token
   - **ID**: `docker-username`
   - Click **Create**

4. Repeat for:
   - **ID**: `docker-password` (your Docker token)
   - **ID**: `docker-registry-url` (e.g., `docker.io`)

### GitHub Credentials (Optional)

For private repositories:
1. Create GitHub Personal Access Token
2. Add as credentials with ID `github-token`

## Step 3: Create Pipeline Job

### Option A: Using Jenkinsfile from Repository (Recommended)

1. Click **New Item**
2. Enter job name: `recommendation-service-ci`
3. Select **Pipeline**
4. Under **Pipeline** section:
   - Definition: **Pipeline script from SCM**
   - SCM: **Git**
   - Repository URL: Your GitHub repo URL
   - Branch: `*/main`
   - Script Path: `jenkinsCICD/Jenkinsfile`
5. Click **Save**

### Option B: Manual Pipeline Configuration

1. Click **New Item**
2. Enter job name: `recommendation-service-ci`
3. Select **Pipeline**
4. Under **Build Triggers**:
   - Check **GitHub hook trigger for GITScm polling**
5. Under **Pipeline**:
   - Definition: **Pipeline script**
   - Paste Jenkinsfile content
6. Click **Save**

## Step 4: Configure GitHub Webhook

### Create Webhook

1. Go to GitHub repository
2. Settings → **Webhooks** → **Add webhook**
3. Configure:
   - **Payload URL**: `http://jenkins.example.com:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Push events
   - **Active**: ✓
4. Click **Add webhook**

### Verify Webhook

1. In GitHub webhook settings, click **Recent Deliveries**
2. Check response status (should be 200)
3. If failed, check Jenkins logs:
   ```bash
   ssh -i your-key.pem ubuntu@jenkins.example.com
   sudo tail -f /var/log/jenkins/jenkins.log | grep github
   ```

## Step 5: Configure Kubernetes Access

### Copy kubeconfig

```bash
# SSH into Jenkins instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Create .kube directory
sudo mkdir -p /var/lib/jenkins/.kube

# Copy your kubeconfig
sudo cp ~/.kube/config /var/lib/jenkins/.kube/config

# Set permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins/.kube
```

### Install Kubernetes Plugin

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search for **Kubernetes**
3. Install:
   - Kubernetes plugin
   - Kubernetes CLI plugin
4. Restart Jenkins

## Step 6: Test the Pipeline

### Manual Trigger

1. Go to `recommendation-service-ci` job
2. Click **Build Now**
3. Monitor build in **Console Output**

### Automatic Trigger

Push a commit to main branch:
```bash
git add .
git commit -m "Test Jenkins pipeline"
git push origin main
```

Jenkins should automatically trigger the pipeline.

## Pipeline Stages

### 1. Checkout
- Clones repository
- Captures git commit message

### 2. Unit Tests
- Installs Python dependencies
- Runs pytest with coverage
- Generates coverage reports

### 3. Code Quality - Linting
- Runs pylint for code analysis
- Runs flake8 for style checking
- Checks code formatting with black
- Checks import sorting with isort

### 4. Build Docker Image
- Builds Docker image with tag: `<image>:<build-number>-<commit-hash>`
- Also tags as `latest`

### 5. Push Docker Image
- Logs into Docker registry
- Pushes both tagged and latest images
- Logs out after push

### 6. Update Kubernetes Manifest
- Updates image tag in `kubernetes/recommendation/deploy.yaml`
- Replaces image reference with new build tag

### 7. Commit and Push Changes
- Commits manifest changes
- Pushes to main branch
- Triggers automatic deployment in cluster

## Troubleshooting

### Jenkins Won't Start

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo systemctl status jenkins
sudo journalctl -u jenkins -n 50
```

### Docker Permission Denied

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Git Push Fails

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo -u jenkins git config --global user.email "jenkins@example.com"
sudo -u jenkins git config --global user.name "Jenkins CI"
```

### Webhook Not Triggering

1. Verify webhook in GitHub settings
2. Check Jenkins logs:
   ```bash
   ssh -i your-key.pem ubuntu@jenkins.example.com
   sudo tail -f /var/log/jenkins/jenkins.log
   ```
3. Ensure Jenkins is accessible from GitHub

### Build Fails with Docker Error

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
id jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

### Kubernetes Connection Issues

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo -u jenkins kubectl config view
sudo -u jenkins kubectl cluster-info
sudo -u jenkins aws sts get-caller-identity
```

## Security Configuration

### Enable HTTPS

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com

# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate
sudo certbot certonly --standalone -d jenkins.example.com

# Configure Nginx as reverse proxy
sudo apt-get install -y nginx
# Configure Nginx to proxy to Jenkins on 8080 with SSL
```

### Configure Authentication

1. Go to **Manage Jenkins** → **Security**
2. Enable **Authorization**
3. Set up user accounts
4. Disable anonymous access

### Use API Tokens

For GitHub webhooks:
1. Go to **Manage Jenkins** → **Manage Users**
2. Click your user → **Configure**
3. Generate API token
4. Use token instead of password

## Backup and Restore

### Backup Jenkins

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins
scp -i your-key.pem ubuntu@jenkins.example.com:jenkins-backup.tar.gz .
```

### Restore Jenkins

```bash
scp -i your-key.pem jenkins-backup.tar.gz ubuntu@jenkins.example.com:
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo systemctl stop jenkins
sudo tar -xzf jenkins-backup.tar.gz -C /
sudo systemctl start jenkins
```

## Monitoring

### Check Disk Space

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
df -h
```

### Check Memory Usage

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
free -h
```

### Monitor Build Queue

```bash
curl -s http://jenkins.example.com:8080/queue/api/json | jq ".items | length"
```

### View Jenkins Logs

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo tail -f /var/log/jenkins/jenkins.log
```

## Customization

### Add More Services

1. Copy Jenkinsfile to service directory
2. Update SERVICE_NAME and SERVICE_PATH
3. Create new Jenkins job

### Add More Pipeline Stages

Edit Jenkinsfile to add:
- Security scanning (SAST)
- Performance testing
- Integration testing
- Deployment to staging
- Smoke tests

### Change Build Triggers

Modify Jenkinsfile to trigger on:
- Pull requests
- Scheduled builds
- Manual triggers
- Webhook events

## Performance Tuning

### Increase Jenkins Memory

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo nano /etc/default/jenkins
# Edit: JAVA_ARGS="-Xmx2g -Xms2g"
sudo systemctl restart jenkins
```

### Parallel Builds

In Jenkinsfile:
```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
    timeout(time: 30, unit: 'MINUTES')
    timestamps()
    parallelsAlwaysFailFast()
}
```

## Quick Reference

```bash
# SSH to Jenkins
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check status
sudo systemctl status jenkins

# View logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart
sudo systemctl restart jenkins

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Backup
sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins

# Check disk
df -h

# Check memory
free -h
```

## Next Steps

1. ✅ Complete initial setup
2. ✅ Add Docker credentials
3. ✅ Create pipeline job
4. ✅ Configure GitHub webhook
5. ✅ Test pipeline
6. ✅ Monitor first build
7. ✅ Set up notifications (Slack/Email)
8. ✅ Configure backup strategy
9. ✅ Enable HTTPS
10. ✅ Document team procedures

## Support

For detailed command reference, see JENKINS_COMMANDS.md
