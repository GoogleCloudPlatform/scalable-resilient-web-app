node('docker') {
  checkout scm
  docker.image('google/cloud-sdk').inside {
    sh('apt-get install curl -y')
    sh('cp test/e2e.sh .')
    sh('./e2e.sh')
  }
}
