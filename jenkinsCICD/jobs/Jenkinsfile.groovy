// Jenkins Job DSL Script
// This file defines Jenkins jobs using the Job DSL plugin

// Recommendation Service CI/CD Pipeline Job
pipelineJob('recommendation-service-ci') {
  description('CI/CD pipeline for recommendation microservice')
  
  // Keep last 10 builds
  properties {
    buildDiscarder {
      strategy {
        logRotator {
          daysToKeepStr('30')
          numToKeepStr('10')
          artifactDaysToKeepStr('')
          artifactNumToKeepStr('')
        }
      }
    }
  }

  // Trigger on GitHub push
  triggers {
    githubPush()
  }

  // Pipeline definition
  definition {
    cps {
      script(readFileAsString('jenkinsCICD/Jenkinsfile'))
      sandbox(true)
    }
  }
}

// Example: Additional job for running tests only
pipelineJob('recommendation-service-tests') {
  description('Run tests for recommendation microservice')
  
  properties {
    buildDiscarder {
      strategy {
        logRotator {
          numToKeepStr('20')
        }
      }
    }
  }

  triggers {
    cron('H 2 * * *')  // Run daily at 2 AM
  }

  definition {
    cps {
      script('''
        pipeline {
          agent any
          
          stages {
            stage('Checkout') {
              steps {
                checkout scm
              }
            }
            
            stage('Run Tests') {
              steps {
                dir('src/recommendation') {
                  sh '''
                    pip install --upgrade pip
                    pip install -r requirements.txt
                    pip install pytest pytest-cov
                    pytest --cov=. --cov-report=html
                  '''
                }
              }
            }
            
            stage('Publish Results') {
              steps {
                publishHTML([
                  reportDir: 'src/recommendation/htmlcov',
                  reportFiles: 'index.html',
                  reportName: 'Coverage Report'
                ])
              }
            }
          }
        }
      ''')
      sandbox(true)
    }
  }
}

// Example: Scheduled build job
pipelineJob('recommendation-service-nightly') {
  description('Nightly build and test for recommendation service')
  
  triggers {
    cron('H 0 * * *')  // Run daily at midnight
  }

  definition {
    cps {
      script('''
        pipeline {
          agent any
          
          stages {
            stage('Build') {
              steps {
                echo 'Building recommendation service...'
                sh 'docker build -t recommendation:nightly src/recommendation'
              }
            }
            
            stage('Test') {
              steps {
                echo 'Running tests...'
                sh 'docker run --rm recommendation:nightly pytest'
              }
            }
          }
        }
      ''')
      sandbox(true)
    }
  }
}
