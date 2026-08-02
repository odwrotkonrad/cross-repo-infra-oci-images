# Purpose

## What It Is

Shared OCI CI base image for the `konradodwrot` repos: `ci-linux`, a
`debian:bookworm-slim` base baking the common CI toolchain (go, che,
render-tpl, lefthook, yq, zsh, clang, make, git, zig, goreleaser,
golangci-lint, terraform, glab), per-arch builds (amd64 bare tags, arm64
`-arm64` suffixed), built by Docker buildx and published to this project's
container registry. A che release (go-modules main) triggers a rebuild here
and chains onward to the `restricted/sandbox` image, which owns its own bake.

## Why It Exists

Every repo's CI repeated the same expensive bootstrap: pull a golang base,
`apt-get` clang/make/zsh, then `go install che@latest` + `lefthook@latest`.
Compiling che from source (1Password CGO SDK + tree-sitter) cost ~4–5 min per
pipeline, per repo, every run. Baking the toolchain once here drops that toil to
a cached image pull.

## Goals

- One shared, versioned CI base image every repo pulls.
- Both arches: amd64 automatic, arm64 manual, `-arm64` tag suffix.
- Single source of truth for CI tool versions (`ci/tool-versions.env`).
- Public-pullable, so cross-project pulls need no auth.
- Fast pipelines: no per-job compile of che, no per-job tool downloads.
- Che releases propagate: rebuild here, then trigger the sandbox image re-bake.
