node('docker') {
  def hash = git url: "${GIT_URL}"
  def app = docker.build("${hash}, "test")
  app.withRun {c ->
    sh "docker logs -f ${c.id}"
  }
}
