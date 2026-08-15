# Purpose

## What It Is

Two CI base images for the `konradodwrot` repos, each one multi-arch buildx
manifest (amd64 native, arm64 qemu-emulated) in this project's container
registry. `ci-linux`: `debian:bookworm-slim` plus the shared CI toolchain (go,
che, render-tpl, lefthook, yq, zsh, clang, make, git, zig, goreleaser,
golangci-lint, terraform, glab, op). `ci-linux-dind`: ci-linux plus the static
docker CLI for docker-in-docker jobs. A che release (go-modules main) rebuilds
here, then chains to the `infra/sandbox` image, which owns its own bake.

## Why It Exists

Every repo's CI ran the same bootstrap: pull a golang base, `apt-get`
clang/make/zsh, `go install che@latest` and `lefthook@latest`. Compiling che
(1Password CGO SDK, tree-sitter) cost ~4–5 min per pipeline. Baking the
toolchain once turns that into a cached image pull.

## Goals

- One shared, versioned CI base image every repo pulls.
- Multi-arch tags: one buildx build per image, MR pipelines warm the cache, tag/main pipelines publish.
- Tool versions pinned in `ci/tool-versions.env`.
- Public-pullable: cross-project pulls need no auth.
- No per-job che compile, no per-job tool downloads.
- Che releases propagate: rebuild here, re-bake the sandbox image.
