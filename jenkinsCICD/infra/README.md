# Jenkins Infrastructure - Terraform Files

This directory contains the Terraform configuration for deploying Jenkins infrastructure on AWS.

## File Structure

### Core Terraform Files

- **providers.tf** - Terraform and AWS provider configuration
- **variables.tf** - Input variables for the infrastructure
- **resources.tf** - AWS resources (EC2, Security Group, IAM, Route53)
- **data.tf** - Data sources (Ubuntu AMI lookup)
- **outputs.tf** - Output values after deployment
- **terraform.tfvars** - Variable values (UPDATE THIS with your values)

### Supporting Files

- **jenkins-init.sh** - EC2 initialization script (installs Jenkins and dependencies)

## File Descriptions

### providers.tf
Defines the Terraform version and AWS provider configuration.
- Requires Terraform >= 1.0
- Uses AWS provider version ~> 6.0
- Configured for ap-south-2 region

### variables.tf
Defines all input variables:
- `cluster_name` - EKS cluster name (required)
- `jenkins_instance_type` - EC2 instance type (default: t3.medium)
- `jenkins_volume_size` - EBS volume size in GB (default: 50)
- `jenkins_key_pair_name` - EC2 key pair name (required)
- `allowed_ssh_cidr` - SSH access CIDR (default: 0.0.0.0/0)
- `route53_zone_id` - Route53 hosted zone ID (required)
- `jenkins_dns_name` - Jenkins DNS name (required)

### resources.tf
Defines AWS resources:
- **aws_security_group** - Security group for Jenkins (ports 22, 8080, 50000)
- **aws_iam_role** - IAM role for Jenkins
- **aws_iam_role_policy** - IAM policy for ECR and EKS access
- **aws_iam_instance_profile** - Instance profile for EC2
- **aws_instance** - EC2 instance running Jenkins
- **aws_eip** - Elastic IP for static public IP
- **aws_route53_record** - DNS record mapping domain to Elastic IP

### data.tf
Defines data sources:
- **aws_ami** - Looks up the latest Ubuntu 22.04 AMI

### outputs.tf
Defines output values:
- `jenkins_instance_id` - EC2 instance ID
- `jenkins_private_ip` - Private IP address
- `jenkins_public_ip` - Elastic IP address
- `jenkins_public_url` - URL using Elastic IP
- `jenkins_dns_url` - URL using DNS name
- `jenkins_dns_name` - DNS name
- `jenkins_security_group_id` - Security group ID
- `jenkins_iam_role_name` - IAM role name
- `jenkins_iam_role_arn` - IAM role ARN

### terraform.tfvars
Contains variable values. **UPDATE THIS FILE** with your AWS details:

```hcl
cluster_name           = "my-eks-cluster"
jenkins_instance_type  = "t3.medium"
jenkins_volume_size    = 50
jenkins_key_pair_name  = "your-ec2-key-pair"      # REQUIRED
allowed_ssh_cidr       = "0.0.0.0/0"              # Restrict to your IP
route53_zone_id        = "Z1234567890ABC"         # REQUIRED
jenkins_dns_name       = "jenkins.example.com"    # REQUIRED
```

### jenkins-init.sh
EC2 initialization script that runs on instance startup. Installs:
- Java 17
- Jenkins
- Docker
- Docker Compose
- kubectl
- AWS CLI v2
- Git
- Python 3
- Build tools
- Jenkins plugins

## Deployment Steps

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Plan

```bash
terraform plan
```

### 3. Apply Configuration

```bash
terraform apply
```

### 4. Get Outputs

```bash
terraform output
```

## Common Commands

```bash
# Initialize
terraform init

# Validate configuration
terraform validate

# Format files
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy

# Get specific output
terraform output jenkins_dns_url

# Show state
terraform show

# Refresh state
terraform refresh
```

## Troubleshooting

### Validation Errors

```bash
terraform validate
```

### Plan Errors

```bash
terraform plan -var-file=terraform.tfvars
```

### State Issues

```bash
terraform refresh
terraform state list
terraform state show aws_instance.jenkins
```

## Best Practices

1. **Always run `terraform plan` before `terraform apply`**
2. **Keep terraform.tfvars in .gitignore** (contains sensitive data)
3. **Use meaningful variable values** in terraform.tfvars
4. **Backup your state file** regularly
5. **Use consistent naming** for resources
6. **Document custom changes** to the configuration

## File Organization Benefits

- **Separation of Concerns**: Each file has a specific purpose
- **Easier Maintenance**: Changes are easier to locate and manage
- **Better Readability**: Smaller files are easier to understand
- **Scalability**: Easy to add new resources or variables
- **Team Collaboration**: Clear structure for multiple developers

## Next Steps

1. Update `terraform.tfvars` with your values
2. Run `terraform init`
3. Run `terraform plan` to review changes
4. Run `terraform apply` to deploy
5. Use `terraform output` to get Jenkins URL
6. Access Jenkins and complete setup

## Support

For issues or questions:
1. Check `terraform validate` output
2. Review `terraform plan` output
3. Check AWS console for resource status
4. Review Jenkins logs on the instance
5. See parent directory README.md for more information
