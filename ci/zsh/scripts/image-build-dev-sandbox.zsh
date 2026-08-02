#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

#[why] configs main SHA -> CONFIGS_REF: busts the che run layer only when configs main moved (unchanged configs keeps the cached layer)
typeset configs_ref=$(git ls-remote https://gitlab.com/konradodwrot/configs.git refs/heads/main | cut -f1)

#[why] etag of the latest che tarball -> CHE_REF: busts the che layer only when che re-published (mirrors the CI jobs)
typeset che_ref=$(curl -fsSI "https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/latest/che_latest_linux_$(uname -m | sed 's/aarch64\|arm64/arm64/;s/x86_64/amd64/').tar.gz" | tr -d '\r' | awk 'tolower($1)=="etag:"{print $2}')

docker build \
  --file $repo_root/ci/dev-sandbox/Dockerfile \
  --build-arg CHE_REF=${che_ref:-latest} \
  --build-arg CONFIGS_REF=$configs_ref \
  --tag dev-sandbox:local \
  $repo_root
##[<] 🤖🤖
