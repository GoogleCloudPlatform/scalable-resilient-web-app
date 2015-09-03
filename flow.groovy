node('docker') {
  try {
    def hash = git url: "${GIT_URL}"
    def app = docker.build("${hash}")
    app.withRun {c ->
      sh "docker logs -f ${c.id}"
    }
  } catch(e) {
    def w = new StringWriter()
    e.printStackTrace(new PrintWriter(w))
    mail subject: "Build failed with ${e.message}", to: '${OWNER_EMAIL}', body: "Failed: ${w}"
    throw e
  }
}
