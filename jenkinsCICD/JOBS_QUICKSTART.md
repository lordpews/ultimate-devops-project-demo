# Jenkins Jobs Quick Start

Define and create Jenkins jobs as Groovy code.

## 5-Minute Setup

### 1. Install Job DSL Plugin

```bash
# SSH to Jenkins
ssh -i your-key.pem ubuntu@jenkins.example.com

# Install plugin
sudo -u jenkins java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar \
  -s http://localhost:8080 \
  install-plugin job-dsl

# Restart Jenkins
sudo systemctl restart jenkins
```

### 2. Create API Token

1. Go to Jenkins UI
2. Click your username (top right)
3. Click **Configure**
4. Click **Add new Token**
5. Copy the token

### 3. Create Jobs

```bash
# Set variables
export JENKINS_URL="http://jenkins.example.com:8080"
export JENKINS_USER="admin"
export JENKINS_TOKEN="your-token-here"

# Run setup
cd jenkinsCICD/jobs
chmod +x setup-jobs.sh
./setup-jobs.sh
```

### 4. Verify

Go to Jenkins UI and you should see:
- ✅ seed-job
- ✅ recommendation-service-ci
- ✅ recommendation-service-tests
- ✅ recommendation-service-nightly

## How It Works

```
Jenkinsfile.groovy (Job definitions)
         ↓
setup-jobs.sh (Creates seed job)
         ↓
Seed Job (Runs Job DSL)
         ↓
Jenkins Jobs Created
```

## Job Definitions

### recommendation-service-ci
- **Trigger**: GitHub push
- **Action**: Full CI/CD pipeline

### recommendation-service-tests
- **Trigger**: Daily at 2 AM
- **Action**: Run tests only

### recommendation-service-nightly
- **Trigger**: Daily at midnight
- **Action**: Build and test

## Modify Jobs

1. Edit `jenkinsCICD/jobs/Jenkinsfile.groovy`
2. Trigger seed job in Jenkins UI
3. Jobs update automatically

## Add New Job

Add to `Jenkinsfile.groovy`:

```groovy
pipelineJob('my-new-job') {
  description('My new job')
  
  triggers {
    githubPush()
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

Then trigger seed job.

## Troubleshooting

### Plugin Not Installing

```bash
# Check Jenkins logs
sudo tail -f /var/log/jenkins/jenkins.log

# Try manual install via UI
# Manage Jenkins → Manage Plugins → Search "Job DSL" → Install
```

### Jobs Not Creating

```bash
# Check seed job logs
# Jenkins UI → seed-job → Console Output

# Verify syntax
# Check Jenkinsfile.groovy for errors
```

### API Token Issues

```bash
# Generate new token
# Jenkins UI → Your User → Configure → Add Token
```

## Files

- `Jenkinsfile.groovy` - Job definitions
- `setup-jobs.sh` - Setup script
- `README.md` - Detailed guide

## Next Steps

1. ✅ Install Job DSL plugin
2. ✅ Create API token
3. ✅ Run setup-jobs.sh
4. ✅ Verify jobs created
5. ✅ Configure GitHub webhook
6. ✅ Test pipeline

See `jobs/README.md` for detailed documentation.
