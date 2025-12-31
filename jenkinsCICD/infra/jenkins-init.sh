#!/bin/bash
set -e

# Jenkins initialization script for Ubuntu 22.04

echo "Starting Jenkins setup..."

# Update system packages
apt-get update
apt-get upgrade -y

# Install Java (required for Jenkins)
apt-get install -y openjdk-17-jdk

# Add Jenkins repository and install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins

# Install Docker
apt-get install -y docker.io

# Add jenkins user to docker group
usermod -aG docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
apt-get install -y unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf aws awscliv2.zip

# Install Git
apt-get install -y git

# Install Python and pip (for recommendation service testing)
apt-get install -y python3 python3-pip python3-venv

# Install additional build tools
apt-get install -y build-essential

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start
sleep 30

# Get initial admin password
JENKINS_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

# Create Jenkins configuration directory
mkdir -p /var/lib/jenkins/init.groovy.d

# Create a Groovy script to install plugins
cat > /var/lib/jenkins/init.groovy.d/install-plugins.groovy << 'EOF'
import jenkins.model.Jenkins
import hudson.model.UpdateSite
import hudson.PluginWrapper
import hudson.model.DownloadService
import java.util.concurrent.TimeUnit

def jenkins = Jenkins.getInstance()
def pluginManager = jenkins.getPluginManager()
def updateCenter = jenkins.getUpdateCenter()

// List of plugins to install
def pluginsToInstall = [
    'git',
    'github',
    'docker-plugin',
    'docker-workflow',
    'kubernetes',
    'kubernetes-cli',
    'pipeline-model-definition',
    'pipeline-stage-view',
    'cobertura',
    'junit',
    'warnings-ng',
    'email-ext',
    'slack',
    'timestamper',
    'log-parser',
    'ansicolor'
]

// Update plugin list
updateCenter.updateAllSites()

// Install plugins
pluginsToInstall.each { pluginName ->
    def plugin = updateCenter.getPlugin(pluginName)
    if (plugin != null) {
        println("Installing plugin: " + pluginName)
        plugin.deploy()
    } else {
        println("Plugin not found: " + pluginName)
    }
}

// Wait for plugin installations to complete
jenkins.pluginManager.plugins.each {
    it.getActive()
}

jenkins.save()
EOF

# Restart Jenkins to apply plugins
systemctl restart jenkins

echo "Jenkins setup completed!"
echo "Jenkins will be available at http://<instance-ip>:8080"
echo "Initial admin password: $JENKINS_PASSWORD"
