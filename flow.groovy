node('gcp-packer') {
  def app = docker.build 'scalable-resilient-web-app'
  app.withRun {c ->
    sh "docker logs -f ${c.id}"
  }
}
