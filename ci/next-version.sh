#!/bin/sh
##[>] 🤖🤖
set -eu

tags_url="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/repository/tags?per_page=100&order_by=version&sort=desc"

fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --connect-timeout 30 --retry 10 --retry-delay 30 --retry-all-errors --header "JOB-TOKEN: ${CI_JOB_TOKEN}" "$1"
  else
    wget -qO- --header="JOB-TOKEN: ${CI_JOB_TOKEN}" "$1"
  fi
}

latest_version=$(
  fetch "$tags_url" \
    | grep -oE '"name":"v[0-9]+\.[0-9]+\.[0-9]+"' \
    | sed -E 's/.*"v([0-9]+\.[0-9]+\.[0-9]+)"/\1/' \
    | sort -t. -k1,1n -k2,2n -k3,3n \
    | tail -1
)

if [ -z "$latest_version" ]; then
  echo "v0.0.1"
  exit 0
fi

major=$(echo "$latest_version" | cut -d. -f1)
minor=$(echo "$latest_version" | cut -d. -f2)
patch=$(echo "$latest_version" | cut -d. -f3)
echo "v${major}.${minor}.$((patch + 1))"
##[<] 🤖🤖
