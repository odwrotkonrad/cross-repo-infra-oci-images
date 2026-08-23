##[>] 🤖
produces:
  - uri: us-central1-docker.pkg.dev/staging-499418/ci/ci-linux
    type: ociImage
    versionEnvVar: OCI_IMAGES_CI_LINUX_REF
    version: {{ env.Getenv "OCI_IMAGES_CI_LINUX_REF" }}
  - uri: us-central1-docker.pkg.dev/staging-499418/ci/ci-linux-dind
    type: ociImage
    versionEnvVar: OCI_IMAGES_CI_LINUX_DIND_REF
    version: {{ env.Getenv "OCI_IMAGES_CI_LINUX_DIND_REF" }}
##[<] 🤖
