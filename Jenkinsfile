node('docker') {
  checkout scm
  docker.image('buildpack-deps:jessie-scm').inside {
    sh('export CLOUDSDK_CORE_DISABLE_PROMPTS=1 ; curl https://sdk.cloud.google.com | bash')
    sh('ln -s /root/google-cloud-sdk/bin/gcloud /usr/bin/gcloud')
    sh('cp test/e2e.sh .')
    sh('./e2e.sh')
  }
}
