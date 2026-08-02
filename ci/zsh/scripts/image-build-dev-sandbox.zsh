#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

#[why] configs main SHA -> CONFIGS_REF: busts the che run layer only when configs main moved (unchanged configs keeps the cached layer)
typeset configs_ref=$(git ls-remote https://gitlab.com/konradodwrot/configs.git refs/heads/main | cut -f1)

docker build \
  --file $repo_root/ci/dev-sandbox/Dockerfile \
  --build-arg CONFIGS_REF=$configs_ref \
  --tag dev-sandbox:local \
  $repo_root
##[<] 🤖🤖
