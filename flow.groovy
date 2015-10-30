node('docker') {
  def hash = git url: "${GIT_URL}"
  docker.image('google/cloud-sdk').inside {
    sh('apt-get install curl -y')
    sh('cp test/e2e.sh .')
    sh('cp test/e2e.sh .')
    sh('./e2e.sh')
  }
}
