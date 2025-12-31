# Jenkins Quick Reference Guide

## SSH Access

```bash
# Connect to Jenkins instance
ssh -i your-key.pem ubuntu@<jenkins-private-ip>

# Switch to jenkins user
sudo su - jenkins

# Check Jenkins status
sudo systemctl status jenkins

# View Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins
```

## Jenkins CLI Commands

```bash
# Get Jenkins version
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 version

# List all jobs
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 list-jobs

# Trigger a build
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 build recommendation-service-ci

# Get build info
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s http://localhost:8080 get-job recommendation-service-ci
```

## Docker Commands on Jenkins

```bash
# SSH into Jenkins instance
ssh -i your-key.pem ubuntu@<jenkins-private-ip>

# List Docker images
sudo docker images

# List running containers
sudo docker ps

# View Docker logs
sudo docker logs <container-id>

# Clean up Docker
sudo docker system prune -a
```

## Kubernetes Commands

```bash
# SSH into Jenkins instance
ssh -i your-key.pem ubuntu@<jenkins-private-ip>

# Check cluster connection
kubectl cluster-info

# Get recommendation service deployment
kubectl get deployment -n default | grep recommendation

# View deployment details
kubectl describe deployment opentelemetry-demo-recommendationservice

# Check pod status
kubectl get pods -n default | grep recommendation

# View pod logs
kubectl logs -f <pod-name>

# Update deployment
kubectl set image deployment/opentelemetry-demo-recommendationservice \
  recommendationservice=<new-image>:tag
```

## Jenkins Configuration Files

```bash
# Jenkins home directory
/var/lib/jenkins

# Jenkins configuration
/var/lib/jenkins/config.xml

# Job configurations
/var/lib/jenkins/jobs/recommendation-service-ci/config.xml

# Jenkins plugins
/var/lib/jenkins/plugins

# Jenkins logs
/var/log/jenkins/jenkins.log

# Jenkins secrets
/var/lib/jenkins/secrets
```

## Backup and Restore

```bash
# Backup Jenkins configuration
sudo tar -czf jenkins-backup.tar.gz /var/lib/jenkins

# Restore Jenkins configuration
sudo tar -xzf jenkins-backup.tar.gz -C /

# Backup specific job
sudo tar -czf recommendation-job-backup.tar.gz \
  /var/lib/jenkins/jobs/recommendation-service-ci
```

## Troubleshooting Commands

```bash
# Check disk space
df -h

# Check memory usage
free -h

# Check Jenkins process
ps aux | grep jenkins

# Check port 8080 usage
sudo netstat -tlnp | grep 8080

# Check Docker daemon
sudo systemctl status docker

# Verify git configuration
sudo -u jenkins git config --list

# Test Docker login
sudo -u jenkins docker login -u <username>

# Check kubeconfig
sudo -u jenkins kubectl config view

# Verify AWS credentials
sudo -u jenkins aws sts get-caller-identity
```

## Performance Tuning

```bash
# Increase Jenkins heap memory
# Edit /etc/default/jenkins
JAVA_ARGS="-Xmx2g -Xms2g"

# Restart Jenkins
sudo systemctl restart jenkins

# Monitor Jenkins memory
watch -n 1 'ps aux | grep jenkins | grep -v grep'
```

## Plugin Management

```bash
# SSH into Jenkins
ssh -i your-key.pem ubuntu@<jenkins-private-ip>

# List installed plugins
sudo find /var/lib/jenkins/plugins -name "*.jpi" | wc -l

# Check plugin versions
sudo ls -la /var/lib/jenkins/plugins/ | grep -E "\.jpi$"

# Remove a plugin
sudo rm /var/lib/jenkins/plugins/<plugin-name>.jpi
sudo systemctl restart jenkins
```

## Credential Management

```bash
# SSH into Jenkins
ssh -i your-key.pem ubuntu@<jenkins-private-ip>

# List credentials (requires Jenkins CLI)
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar \
  -s http://localhost:8080 \
  list-credentials-as-xml system::system::jenkins

# Update credentials via Groovy script
# Create a script in /var/lib/jenkins/init.groovy.d/
```

## Monitoring and Alerts

```bash
# Monitor build queue
watch -n 5 'curl -s http://localhost:8080/queue/api/json | jq ".items | length"'

# Monitor active builds
watch -n 5 'curl -s http://localhost:8080/api/json | jq ".jobs[] | select(.color != \"notbuilt\") | .name"'

# Check Jenkins health
curl -s http://localhost:8080/api/json | jq ".nodeDescription"
```

## Common Issues and Solutions

### Jenkins Won't Start
```bash
# Check logs
sudo journalctl -u jenkins -n 100

# Check Java installation
java -version

# Verify permissions
sudo chown -R jenkins:jenkins /var/lib/jenkins
```

### Build Fails with Docker Error
```bash
# Verify docker group membership
id jenkins

# Add jenkins to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins
sudo systemctl restart jenkins
```

### Git Push Fails
```bash
# Configure git user
sudo -u jenkins git config --global user.email "jenkins@example.com"
sudo -u jenkins git config --global user.name "Jenkins CI"

# Test git access
sudo -u jenkins git clone <repo-url> /tmp/test-repo
```

### Kubernetes Connection Issues
```bash
# Verify kubeconfig
sudo -u jenkins kubectl config view

# Test cluster connection
sudo -u jenkins kubectl cluster-info

# Check credentials
sudo -u jenkins aws sts get-caller-identity
```

## Useful Links

- Jenkins Documentation: https://www.jenkins.io/doc/
- Jenkins Plugins: https://plugins.jenkins.io/
- Pipeline Syntax: https://www.jenkins.io/doc/book/pipeline/
- Groovy Documentation: https://groovy-lang.org/documentation.html
