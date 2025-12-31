# Jenkins Infrastructure Setup Guide

This guide covers deploying Jenkins infrastructure on AWS using Terraform.

## Architecture Overview

```
Internet
    ↓
Route53 DNS (jenkins.example.com)
    ↓
Elastic IP (54.123.45.67)
    ↓
Public Subnet
    ↓
EC2 Instance (t3.medium)
    ├─ Jenkins Server
    ├─ Docker
    ├─ kubectl
    └─ AWS CLI
```

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform installed locally
3. AWS CLI configured
4. EC2 key pair created in your region
5. Route53 hosted zone for your domain
6. Domain registered and pointing to Route53 nameservers

## Step 1: Get Your AWS Information

### Get EC2 Key Pair Name

```bash
# List your EC2 key pairs
aws ec2 describe-key-pairs --region ap-south-2

# Note the KeyName you want to use
```

### Get Route53 Zone ID

```bash
# List your hosted zones
aws route53 list-hosted-zones

# Find your domain and copy the Zone ID (e.g., Z1234567890ABC)
```

## Step 2: Configure Terraform Variables

Edit `jenkinsCICD/infra/terraform.tfvars` and update:

```hcl
# Your cluster name
cluster_name = "my-eks-cluster"

# EC2 key pair name (REQUIRED)
jenkins_key_pair_name = "your-ec2-key-pair-name"

# Route53 Zone ID (REQUIRED)
route53_zone_id = "Z1234567890ABC"

# Jenkins DNS name (REQUIRED)
jenkins_dns_name = "jenkins.example.com"

# Optional: Restrict SSH access to your IP
allowed_ssh_cidr = "203.0.113.0/32"  # Replace with your IP
```

## Step 3: Deploy Infrastructure

```bash
# Navigate to infra directory
cd jenkinsCICD/infra

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

Terraform will create:
- EC2 instance (t3.medium)
- Security group with ports 22, 8080, 50000
- IAM role for Docker registry and EKS access
- Elastic IP (static public IP)
- Route53 DNS record
- 50GB EBS volume

## Step 4: Verify Deployment

```bash
# Get Jenkins details
terraform output

# Get DNS URL
terraform output jenkins_dns_url

# Get public IP
terraform output jenkins_public_ip

# Get instance ID
terraform output jenkins_instance_id
```

## Step 5: Wait for Jenkins to Start

Jenkins takes 2-3 minutes to start. Monitor the initialization:

```bash
# SSH into the instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check Jenkins status
sudo systemctl status jenkins

# View initialization logs
sudo tail -f /var/log/jenkins/jenkins.log

# Get initial admin password (after Jenkins starts)
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Step 6: Access Jenkins

1. Wait for DNS to propagate (usually 5-30 minutes)
2. Open browser: `http://jenkins.example.com:8080`
3. Enter initial admin password from step 5
4. Complete setup wizard

## Troubleshooting

### DNS Not Resolving

```bash
# Check Route53 record
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --query "ResourceRecordSets[?Name=='jenkins.example.com.']"

# Verify DNS
dig jenkins.example.com

# Wait for TTL (5 minutes) and try again
```

### Can't SSH to Instance

```bash
# Verify security group allows SSH
aws ec2 describe-security-groups --group-ids <sg-id>

# Check instance status
aws ec2 describe-instances --instance-ids <instance-id>

# Verify key pair permissions
chmod 400 your-key.pem
```

### Jenkins Won't Start

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Check Java installation
java -version

# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins
```

### Terraform Errors

```bash
# Validate configuration
terraform validate

# Check variable values
terraform plan -var-file=terraform.tfvars

# Destroy and retry
terraform destroy
terraform apply
```

## Security Best Practices

### 1. Restrict SSH Access

Update `terraform.tfvars`:
```hcl
allowed_ssh_cidr = "YOUR_IP/32"  # Replace with your IP
```

### 2. Enable HTTPS

After Jenkins starts, set up SSL:
```bash
ssh -i your-key.pem ubuntu@jenkins.example.com
sudo apt-get install -y certbot python3-certbot-nginx
sudo certbot certonly --standalone -d jenkins.example.com
```

### 3. Configure Jenkins Authentication

1. Go to **Manage Jenkins** → **Security**
2. Enable **Authorization**
3. Create user accounts
4. Disable anonymous access

### 4. Use API Tokens

For GitHub webhooks and CLI:
1. Go to **Manage Jenkins** → **Manage Users**
2. Click your user → **Configure**
3. Generate API token
4. Use token instead of password

### 5. Regular Backups

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Backup Jenkins
sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins

# Download backup
scp -i your-key.pem ubuntu@jenkins.example.com:jenkins-backup.tar.gz .
```

## Infrastructure Costs

| Resource | Cost | Notes |
|----------|------|-------|
| EC2 t3.medium | ~$30/month | Adjust instance type as needed |
| Elastic IP | Free | Free when associated to running instance |
| Route53 Zone | $0.50/month | Per hosted zone |
| Route53 Queries | ~$0.40/million | Negligible for typical usage |
| EBS Volume (50GB) | ~$5/month | gp3 storage |
| **Total** | **~$35.50/month** | Approximate |

## Scaling Considerations

### Increase Instance Size

```bash
# Update terraform.tfvars
jenkins_instance_type = "t3.large"

# Apply changes
terraform apply
```

### Increase Storage

```bash
# Update terraform.tfvars
jenkins_volume_size = 100

# Apply changes
terraform apply
```

### Add Jenkins Agents

For distributed builds, add agent nodes:
```bash
# Create additional EC2 instances
# Configure as Jenkins agents
# See Jenkins documentation for agent setup
```

## Monitoring

### CloudWatch Metrics

```bash
# View EC2 metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/EC2 \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceId,Value=<instance-id> \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### Jenkins Logs

```bash
# SSH into instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# View logs
sudo tail -f /var/log/jenkins/jenkins.log

# Check disk space
df -h

# Check memory
free -h
```

## Cleanup

To destroy all infrastructure:

```bash
cd jenkinsCICD/infra
terraform destroy
```

This will remove:
- EC2 instance
- Security group
- IAM role and policies
- Elastic IP
- Route53 DNS record
- EBS volume

## Quick Reference

```bash
# Initialize
cd jenkinsCICD/infra && terraform init

# Plan
terraform plan

# Deploy
terraform apply

# Get outputs
terraform output

# SSH to instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Get initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Destroy
terraform destroy
```

## Next Steps

1. ✅ Configure terraform.tfvars
2. ✅ Deploy infrastructure
3. ✅ Verify DNS resolution
4. ✅ Access Jenkins
5. ✅ Complete Jenkins setup (see JENKINS_SETUP.md)
6. ✅ Configure credentials
7. ✅ Create pipeline job
8. ✅ Set up GitHub webhook

## Support

For issues:
1. Check logs: `sudo tail -f /var/log/jenkins/jenkins.log`
2. Verify DNS: `dig jenkins.example.com`
3. Check security group: `aws ec2 describe-security-groups`
4. Review Terraform state: `terraform show`

See JENKINS_SETUP.md for Jenkins-specific configuration.
