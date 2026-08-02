# Purpose

## What It Is

Shared OCI container images for the `konradodwrot` repos, per-arch builds
(amd64 bare tags, arm64 `-arm64` suffixed), built by Docker buildx and
published to this project's container registry. Two images: `ci-linux`, a `debian:bookworm-slim` base
baking the common CI toolchain (go, che, render-tpl, lefthook, yq, zsh, clang,
make, git, zig, goreleaser, golangci-lint, terraform, glab); `dev-sandbox`, a bare
`debian:bookworm-slim` carrying only che and its run prerequisites, loading the
public `configs` repo's `zsh/base-linux` profile via a remote che profile ref
(zsh, rg and brew installed by the profile's own scripts), a bare-minimal zsh
sandbox shell.

## Why It Exists

Every repo's CI repeated the same expensive bootstrap: pull a golang base,
`apt-get` clang/make/zsh, then `go install che@latest` + `lefthook@latest`.
Compiling che from source (1Password CGO SDK + tree-sitter) cost ~4–5 min per
pipeline, per repo, every run. Baking the toolchain once here drops that toil to
a cached image pull. The dev-sandbox image bakes the minimal zsh config from one
remote che profile ref, so local sandboxes pull a ready image instead of
building one.

## Goals

- One shared, versioned CI base image every repo pulls.
- One published bare-minimal zsh sandbox image local sandboxes pull.
- Both arches: amd64 automatic (ci-linux), arm64 + dev-sandbox manual, `-arm64` tag suffix.
- Single source of truth for CI tool versions (`ci/tool-versions.env`).
- Public-pullable, so cross-project pulls need no auth.
- Fast pipelines: no per-job compile of che, no per-job tool downloads.
- No secrets baked: the zsh/base-linux profile carries no secret refs or templates.
