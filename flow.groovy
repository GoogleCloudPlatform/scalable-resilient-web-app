node('docker') {
  def hash = git url: "${GIT_URL}"
  docker.image('buildpack-deps:jessie-scm').inside {
    sh('exit 1')
  }
}
