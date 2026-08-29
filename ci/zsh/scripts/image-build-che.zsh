#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

typeset che_version=$(sed -n 's#^GO_MODULES_CHE_REF=che/v##p' $repo_root/.repo/upstream.env)
[[ -n $che_version ]] || fn-exit-with 1 "${0:t}: GO_MODULES_CHE_REF missing in .repo/upstream.env"

docker build \
  --file $repo_root/ci/che/Dockerfile \
  --target che \
  --build-arg CHE_VERSION=$che_version \
  --tag che:local \
  --tag che:v$che_version \
  $repo_root
##[<] 🤖🤖
