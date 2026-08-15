#!/bin/zsh

emulate -LR zsh
setopt errexit pipefail
autoload -Uz fn-exit-with

##[>] 🤖🤖
typeset repo_root=$(git -C ${0:A:h} rev-parse --show-toplevel)

(( $+commands[docker] )) || fn-exit-with 1 "${0:t}: docker not found"

#[why] busts the Dockerfile che layer only when che re-published (unchanged che keeps the cached layer)
typeset che_etag=$(curl --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors -fsSI "https://gitlab.com/api/v4/projects/konradodwrot%2Fgo-modules/packages/generic/che/latest/che_latest_linux_amd64.tar.gz" | tr -d '\r' | awk 'tolower($1)=="etag:"{print $2}')

docker build \
  --file $repo_root/ci/ci-linux/Dockerfile \
  --target ci-linux \
  --build-arg CHE_ETAG=$che_etag \
  --tag ci-linux:local \
  $repo_root
##[<] 🤖🤖
