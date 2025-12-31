# Jenkins Jobs as Code

This directory contains Jenkins job definitions using Groovy Job DSL.

## Files

- **Jenkinsfile.groovy** - Job DSL script defining all Jenkins jobs
- **setup-jobs.sh** - Script to create jobs in Jenkins
- **README.md** - This file

## Prerequisites

1. Jenkins running and accessible
2. Job DSL plugin installed
3. Jenkins API token for authentication

## Installation

### Step 1: Install Job DSL Plugin

```bash
# SSH to Jenkins instance
ssh -i your-key.pem ubuntu@jenkins.example.com

# Install Job DSL plugin via Jenkins CLI
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar \
  -s http://localhost:8080 \
  install-plugin job-dsl

# Restart Jenkins
sudo systemctl restart jenkins
```

Or via Jenkins UI:
1. Go to **Manage Jenkins** → **Manage Plugins**
2. Search for "Job DSL"
3. Install and restart

### Step 2: Create API Token

1. Go to Jenkins → **Manage Jenkins** → **Manage Users**
2. Click your user → **Configure**
3. Click **Add new Token**
4. Copy the token

### Step 3: Setup Jobs

```bash
# Set environment variables
export JENKINS_URL="http://jenkins.example.com:8080"
export JENKINS_USER="admin"
export JENKINS_TOKEN="your-api-token"

# Run setup script
chmod +x setup-jobs.sh
./setup-jobs.sh
```

Or manually:

```bash
# SSH to Jenkins
ssh -i your-key.pem ubuntu@jenkins.example.com

# Copy Jenkinsfile.groovy to Jenkins
sudo cp Jenkinsfile.groovy /var/lib/jenkins/jobs/

# Restart Jenkins
sudo systemctl restart jenkins
```

## Job Definitions

### 1. recommendation-service-ci

Main CI/CD pipeline for the recommendation service.

**Triggers**: GitHub push events
**Actions**:
- Checkout code
- Run unit tests
- Code quality checks
- Build Docker image
- Push to registry
- Update K8s manifest
- Commit changes

### 2. recommendation-service-tests

Runs tests only, useful for quick feedback.

**Triggers**: Daily at 2 AM
**Actions**:
- Checkout code
- Run pytest with coverage
- Publish coverage report

### 3. recommendation-service-nightly

Nightly build and test job.

**Triggers**: Daily at midnight
**Actions**:
- Build Docker image
- Run tests in container

## Adding New Jobs

Edit `Jenkinsfile.groovy` and add a new job definition:

```groovy
pipelineJob('my-new-job') {
  description('Description of my job')
  
  triggers {
    githubPush()  // or cron('H 2 * * *') for scheduled
  }

  definition {
    cps {
      script('''
        pipeline {
          agent any
          
          stages {
            stage('Build') {
              steps {
                echo 'Building...'
              }
            }
          }
        }
      ''')
      sandbox(true)
    }
  }
}
```

Then re-run the setup script or trigger the seed job.

## Modifying Jobs

1. Edit `Jenkinsfile.groovy`
2. Trigger the seed job in Jenkins UI
3. Or run: `./setup-jobs.sh`

The seed job will update existing jobs with new definitions.

## Job DSL Syntax

### Triggers

```groovy
// GitHub push
triggers {
  githubPush()
}

// Scheduled (cron)
triggers {
  cron('H 2 * * *')  // Daily at 2 AM
}

// Poll SCM
triggers {
  pollSCM('H/15 * * * *')  // Every 15 minutes
}
```

### Properties

```groovy
properties {
  buildDiscarder {
    strategy {
      logRotator {
        daysToKeepStr('30')
        numToKeepStr('10')
      }
    }
  }
}
```

### Pipeline Definition

```groovy
definition {
  cps {
    script(readFileAsString('path/to/Jenkinsfile'))
    sandbox(true)
  }
}
```

## Troubleshooting

### Job DSL Plugin Not Found

```bash
# Install via CLI
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar \
  -s http://localhost:8080 \
  install-plugin job-dsl

# Restart
sudo systemctl restart jenkins
```

### Jobs Not Creating

1. Check seed job logs in Jenkins UI
2. Verify Job DSL syntax
3. Check Jenkins logs: `sudo tail -f /var/log/jenkins/jenkins.log`

### API Token Issues

```bash
# Generate new token
# Go to Jenkins UI → Manage Users → Your User → Configure → Add Token
```

### Permission Denied

```bash
# Ensure user has job creation permissions
# Go to Jenkins → Manage Jenkins → Configure Global Security
# Set appropriate permissions for your user
```

## Advanced: Using External Groovy Files

Instead of inline scripts, reference external files:

```groovy
pipelineJob('my-job') {
  definition {
    cps {
      script(readFileAsString('jobs/pipelines/my-pipeline.groovy'))
      sandbox(true)
    }
  }
}
```

Create `jobs/pipelines/my-pipeline.groovy`:

```groovy
pipeline {
  agent any
  
  stages {
    stage('Build') {
      steps {
        echo 'Building...'
      }
    }
  }
}
```

## Best Practices

1. **Version Control** - Keep Jenkinsfile.groovy in Git
2. **Sandbox Mode** - Use `sandbox(true)` for security
3. **Descriptive Names** - Use clear job names
4. **Documentation** - Add descriptions to jobs
5. **Cleanup** - Set build discarder to manage disk space
6. **Testing** - Test Job DSL changes before applying

## References

- [Job DSL Plugin](https://plugins.jenkins.io/job-dsl/)
- [Job DSL API](https://jenkinsci.github.io/job-dsl-plugin/)
- [Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/)

## Quick Commands

```bash
# Setup jobs
./setup-jobs.sh

# Check Jenkins status
sudo systemctl status jenkins

# View logs
sudo tail -f /var/log/jenkins/jenkins.log

# Restart Jenkins
sudo systemctl restart jenkins

# Trigger seed job
curl -X POST http://jenkins.example.com:8080/job/seed-job/build \
  -u admin:token
```

## Next Steps

1. ✅ Install Job DSL plugin
2. ✅ Create API token
3. ✅ Run setup-jobs.sh
4. ✅ Verify jobs in Jenkins UI
5. ✅ Configure GitHub webhook
6. ✅ Test pipeline
