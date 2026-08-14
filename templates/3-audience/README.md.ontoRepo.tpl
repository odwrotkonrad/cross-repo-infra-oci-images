# oci-images

Shared OCI container images for the `konradodwrot` repos.

{{ renderMarkdown "assets/docs-agents/purpose.md" "normalize-headings" }}

## Images

Each arch builds in its own CI job: amd64 owns the bare tags (`:vX.Y.Z`
immutable, pinned by consumers, `:latest` moving, `:$CI_COMMIT_SHORT_SHA`
immutable), arm64 publishes the same set suffixed `-arm64`. amd64 runs
automatically, arm64 is a manual job (qemu-emulated builds are slow).

### ci-linux

`registry.gitlab.com/konradodwrot/infra/oci-images/ci-linux:latest`

`FROM debian:bookworm-slim` plus the shared CI toolchain, so jobs skip the
per-pipeline `apt-get` + `go install` + `curl` bootstrap:

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

## Versions

Tool pins live in `ci/tool-versions.env`: bump there. The build `COPY`s the
file in and sources it per `RUN` in `ci/ci-linux/Dockerfile`. Host
provisioning lives separately, in
`configs/ci/zsh/scripts/installs/00-ci-deps.zsh`.

## Build

CI builds with Docker buildx on Dockerfile or `ci/tool-versions.env` changes,
on `main`, or manually. A `main` pipeline (or a che release via
`BUILD_ALL_IMAGES`) also triggers the `restricted/sandbox` re-bake. See
`.gitlab-ci.yml`.

## License

MIT: see [LICENSE](LICENSE).
