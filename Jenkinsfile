node('docker') {
  checkout scm
  docker.image('buildpack-deps:jessie-scm').inside {
    sh('exit 1')
  }
}
