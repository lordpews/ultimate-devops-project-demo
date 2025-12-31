# Jenkins CI/CD for Recommendation Microservice

Complete Jenkins CI/CD setup for automated testing, building, and deploying the recommendation microservice.

## Quick Start

1. **Configure Infrastructure**
   - Edit `infra/terraform.tfvars` with your AWS details
   - See `INFRASTRUCTURE_SETUP.md` for detailed instructions

2. **Deploy Infrastructure**
   ```bash
   cd infra
   terraform init
   terraform apply
   ```

3. **Configure Jenkins**
   - Access Jenkins at `http://jenkins.example.com:8080`
   - See `JENKINS_CONFIGURATION.md` for setup steps

4. **Test Pipeline**
   - Push a commit to trigger the pipeline
   - Monitor build in Jenkins dashboard

## Documentation

### Infrastructure Setup
**File**: `INFRASTRUCTURE_SETUP.md`

Covers:
- AWS prerequisites
- Terraform configuration
- Infrastructure deployment
- DNS and Elastic IP setup
- Security best practices
- Troubleshooting

### Jenkins Configuration
**File**: `JENKINS_CONFIGURATION.md`

Covers:
- Initial Jenkins setup
- Adding credentials
- Creating pipeline jobs
- GitHub webhook configuration
- Kubernetes integration
- Testing the pipeline
- Troubleshooting

### Command Reference
**File**: `JENKINS_COMMANDS.md`

Quick reference for:
- SSH access
- Jenkins CLI commands
- Docker commands
- Kubernetes commands
- Troubleshooting commands
- Performance tuning

## Directory Structure

```
jenkinsCICD/
├── README.md                          # This file
├── INFRASTRUCTURE_SETUP.md            # Infrastructure deployment guide
├── JENKINS_CONFIGURATION.md           # Jenkins setup guide
├── JENKINS_COMMANDS.md                # Command reference
├── jenkins-env-example.sh             # Environment variables template
├── Jenkinsfile                        # CI/CD pipeline definition
├── infra/
│   ├── terraform.tfvars               # Terraform variables (UPDATE THIS)
│   ├── jenkins.tf                     # Terraform configuration
│   └── jenkins-init.sh                # EC2 initialization script
└── src/
    └── test_recommendation.py         # Sample unit tests
```

## Pipeline Overview

The Jenkins pipeline automatically:

1. **Checkout** - Clones your repository
2. **Unit Tests** - Runs pytest with coverage
3. **Code Quality** - Linting with pylint, flake8, black, isort
4. **Build Docker Image** - Creates Docker image with semantic versioning
5. **Push Docker Image** - Pushes to Docker registry
6. **Update K8s Manifest** - Updates deployment manifest with new image tag
7. **Commit & Push** - Commits changes back to repository

## Architecture

```
GitHub Repository
    ↓ (Webhook on push)
Jenkins Pipeline
    ├─ Unit Tests
    ├─ Code Quality
    ├─ Docker Build
    ├─ Docker Push
    ├─ K8s Manifest Update
    └─ Git Commit & Push
    ↓
Kubernetes Cluster
    ↓
Recommendation Service (Updated)
```

## Getting Started

### 1. Prerequisites

- AWS Account
- Terraform installed
- AWS CLI configured
- EC2 key pair created
- Route53 hosted zone
- GitHub repository

### 2. Configure Variables

Edit `infra/terraform.tfvars`:

```hcl
cluster_name           = "my-eks-cluster"
jenkins_instance_type  = "t3.medium"
jenkins_volume_size    = 50
jenkins_key_pair_name  = "your-key-pair"      # REQUIRED
route53_zone_id        = "Z1234567890ABC"     # REQUIRED
jenkins_dns_name       = "jenkins.example.com" # REQUIRED
allowed_ssh_cidr       = "0.0.0.0/0"          # Restrict to your IP
```

### 3. Deploy Infrastructure

```bash
cd infra
terraform init
terraform plan
terraform apply
```

### 4. Access Jenkins

```bash
# Get Jenkins URL
terraform output jenkins_dns_url

# Open in browser: http://jenkins.example.com:8080
```

### 5. Complete Jenkins Setup

Follow `JENKINS_CONFIGURATION.md` to:
- Add Docker credentials
- Create pipeline job
- Configure GitHub webhook
- Test the pipeline

## Key Features

✅ **Automated Testing** - Unit tests on every commit
✅ **Code Quality** - Linting and style checks
✅ **Docker Integration** - Automatic image building and pushing
✅ **Kubernetes Updates** - Manifest updates with new image tags
✅ **Git Integration** - Automatic commits back to repository
✅ **Scalable** - Easy to add more services
✅ **Secure** - IAM roles, credential management, security groups
✅ **Observable** - Detailed logs, coverage reports, quality metrics

## Configuration Files

### terraform.tfvars
Update with your AWS details:
- EC2 key pair name
- Route53 zone ID
- Jenkins DNS name
- SSH CIDR (optional)

### Jenkinsfile
Pipeline definition with stages:
- Checkout
- Unit Tests
- Code Quality
- Build Docker Image
- Push Docker Image
- Update K8s Manifest
- Commit & Push

### jenkins-init.sh
EC2 initialization script that installs:
- Java 17
- Jenkins
- Docker
- kubectl
- AWS CLI
- Python 3
- Build tools

## Costs

| Resource | Cost | Notes |
|----------|------|-------|
| EC2 t3.medium | ~$30/month | Adjust as needed |
| Elastic IP | Free | When associated |
| Route53 Zone | $0.50/month | Per zone |
| EBS Volume (50GB) | ~$5/month | gp3 storage |
| **Total** | **~$35.50/month** | Approximate |

## Security

### Recommended Practices

1. **Restrict SSH Access** - Update `allowed_ssh_cidr` to your IP
2. **Enable HTTPS** - Set up SSL certificate
3. **Configure Authentication** - Require login for all users
4. **Use API Tokens** - For automated access
5. **Regular Backups** - Backup Jenkins configuration
6. **Monitor Access** - Enable audit logging
7. **Update Regularly** - Keep Jenkins and plugins updated

See `INFRASTRUCTURE_SETUP.md` for detailed security recommendations.

## Troubleshooting

### Can't Access Jenkins

```bash
# Check DNS
dig jenkins.example.com

# Check security group
aws ec2 describe-security-groups --group-ids <sg-id>

# Check instance status
aws ec2 describe-instances --instance-ids <instance-id>
```

### Webhook Not Triggering

```bash
# Verify Jenkins is accessible
curl http://jenkins.example.com:8080

# Check GitHub webhook delivery
# Go to webhook settings → Recent Deliveries

# Check Jenkins logs
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo tail -f /var/log/jenkins/jenkins.log
```

### Build Fails

```bash
# SSH to Jenkins
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check Docker
sudo docker ps
sudo docker logs <container-id>

# Check disk space
df -h
```

See `JENKINS_COMMANDS.md` for more troubleshooting commands.

## Customization

### Add More Services

1. Copy Jenkinsfile to service directory
2. Update SERVICE_NAME and SERVICE_PATH
3. Create new Jenkins job

### Add More Pipeline Stages

Edit Jenkinsfile to add:
- Security scanning
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

## Monitoring

### Jenkins Health

```bash
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check status
sudo systemctl status jenkins

# Check logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check disk
df -h

# Check memory
free -h
```

### Build Metrics

```bash
# Monitor build queue
curl -s http://jenkins.example.com:8080/queue/api/json | jq ".items | length"

# Monitor active builds
curl -s http://jenkins.example.com:8080/api/json | jq ".jobs[] | select(.color != \"notbuilt\") | .name"
```

## Cleanup

To destroy all infrastructure:

```bash
cd infra
terraform destroy
```

This removes:
- EC2 instance
- Security group
- IAM role and policies
- Elastic IP
- Route53 DNS record
- EBS volume

## Next Steps

1. ✅ Configure `infra/terraform.tfvars`
2. ✅ Deploy infrastructure
3. ✅ Access Jenkins
4. ✅ Complete Jenkins setup
5. ✅ Add Docker credentials
6. ✅ Create pipeline job
7. ✅ Configure GitHub webhook
8. ✅ Test pipeline
9. ✅ Monitor builds
10. ✅ Set up notifications

## Support

For detailed information:
- **Infrastructure**: See `INFRASTRUCTURE_SETUP.md`
- **Jenkins Setup**: See `JENKINS_CONFIGURATION.md`
- **Commands**: See `JENKINS_COMMANDS.md`

## Files

- `Jenkinsfile` - Pipeline definition
- `infra/jenkins.tf` - Terraform configuration
- `infra/jenkins-init.sh` - EC2 initialization
- `infra/terraform.tfvars` - Variables (UPDATE THIS)
- `src/test_recommendation.py` - Sample tests
- `jenkins-env-example.sh` - Environment template

## License

This Jenkins CI/CD setup is part of the OpenTelemetry Demo project.
