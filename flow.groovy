node('docker') {
  def hash = git url: "${GIT_URL}"
  def app = docker.build("${hash}")
  app.withRun {c ->
    sh "docker logs -f ${c.id}"
  }
  catchError {
    mail subject: 'Build Broken', to: '${OWNER_EMAIL}', body: '${currentBuild.result}'
    error 'An error occurred in the build'
  }
}
