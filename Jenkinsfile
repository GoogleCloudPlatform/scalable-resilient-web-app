node('docker') {
  checkout scm
  docker.image('buildpack-deps:jessie-scm').inside {
    sh('apt-get install curl -y')
    sh('cp test/e2e.sh .')
    sh('cp test/e2e.sh .')
    sh('./e2e.sh')
  }
}
