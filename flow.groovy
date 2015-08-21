node('docker') {
  git url: 'https://github.com/GoogleCloudPlatform/scalable-resilient-web-app.git'
  def app = docker.build 'scalable-resilient-web-app'
  app.withRun {c ->
    sh "docker logs -f ${c.id}"
  }
}
