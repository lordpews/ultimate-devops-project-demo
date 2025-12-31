#!/bin/bash
# Script to setup Jenkins jobs using Job DSL

set -e

JENKINS_URL="${JENKINS_URL:-http://localhost:8080}"
JENKINS_USER="${JENKINS_USER:-admin}"
JENKINS_TOKEN="${JENKINS_TOKEN:-}"
JOBS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Jenkins jobs..."
echo "Jenkins URL: $JENKINS_URL"
echo "Jenkins User: $JENKINS_USER"

# Check if Jenkins is accessible
echo "Checking Jenkins connectivity..."
if ! curl -s -f "$JENKINS_URL/api/json" > /dev/null; then
    echo "Error: Cannot connect to Jenkins at $JENKINS_URL"
    exit 1
fi

# Create seed job if it doesn't exist
echo "Creating/updating seed job..."
curl -X POST "$JENKINS_URL/createItem?name=seed-job" \
  -H "Content-Type: application/xml" \
  -u "$JENKINS_USER:$JENKINS_TOKEN" \
  -d @- << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Seed job to create other jobs using Job DSL</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <scm class="hudson.scm.NullSCM"/>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <javaposse.jobdsl.plugin.ExecuteDslScripts plugin="job-dsl@1.87">
      <targets>jobs/Jenkinsfile.groovy</targets>
      <usingScriptText>false</usingScriptText>
      <sandbox>true</sandbox>
      <ignoreExisting>false</ignoreExisting>
      <ignoreMissingFiles>false</ignoreMissingFiles>
      <failOnMissingPlugin>false</failOnMissingPlugin>
      <unstableOnDeprecation>false</unstableOnDeprecation>
      <removedJobAction>IGNORE</removedJobAction>
      <removedViewAction>IGNORE</removedViewAction>
      <lookupStrategy>JENKINS_ROOT</lookupStrategy>
    </javaposse.jobdsl.plugin.ExecuteDslScripts>
  </builders>
  <publishers/>
  <buildWrappers/>
</project>
EOF

echo "Seed job created/updated"

# Trigger seed job to create other jobs
echo "Triggering seed job to create jobs..."
curl -X POST "$JENKINS_URL/job/seed-job/build" \
  -u "$JENKINS_USER:$JENKINS_TOKEN"

echo "Jobs setup initiated. Check Jenkins UI for progress."
echo "Access Jenkins at: $JENKINS_URL"
