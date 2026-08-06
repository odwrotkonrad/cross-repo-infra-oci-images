# oci-images

Shared OCI container images for the `konradodwrot` repos.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Images

The image builds per arch, one CI job each: amd64 owns the bare tags
(`:vX.Y.Z` immutable release consumers pin, `:latest` moving,
`:$CI_COMMIT_SHORT_SHA` immutable), arm64 publishes the same set with an
`-arm64` suffix. The amd64 build is automatic; arm64 is a manual pipeline job
(qemu-emulated arm64 builds are slow).

### ci-linux

`registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest`

`FROM debian:bookworm-slim`, baking the shared CI toolchain so consuming jobs
skip the per-pipeline `apt-get` + `go install` + `curl` bootstrap:

| Tool | Purpose |
| ---- | ------- |
| go, clang, make, git | core build toolchain (CGO for che/tree-sitter) |
| che | dotfile loader, renders repo + host templates |
| render-tpl | ad-hoc template rendering |
| lefthook | git hooks (pre-commit docs check) |
| yq | YAML query |
| zig | linux cross-compile backend (goreleaser) |
| goreleaser | go release builds |
| terraform | IaC (infra/git-repos) |
| glab | GitLab CLI |

## Consume

```yaml
variables:
  CI_IMAGE: registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:vX.Y.Z

validate-pre-commit-all:
  image: $CI_IMAGE
  script:
    - make repo-ci-precommit-all
```

The images are public-pullable (public repo), so cross-project pulls need no auth.

## Versions

Tool pins live in one place: `ci/tool-versions.env`. Bump there; the file is
`COPY`-ed into the build and sourced per `RUN` in `ci/ci-linux/Dockerfile`. This is the
single source of truth for CI-image tool versions (host provisioning still lives in
`configs/ci/zsh/scripts/installs/00-ci-deps.zsh`).

## Build

CI builds the image with Docker buildx on changes to the Dockerfile /
`ci/tool-versions.env`, on `main`, or manually. A `main` pipeline (and a che
release arriving via `BUILD_ALL_IMAGES`) also triggers the
`restricted/sandbox` image re-bake. See `.gitlab-ci.yml`.

## License

MIT — see [LICENSE](LICENSE).
