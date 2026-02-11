#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

cat <<EOF
Running loop....

for i in {1..1000}; do
  curl -s -H "Host: webapp.abhyas.local" http://127.0.0.1/ | head -n 1
done | sort | uniq -c

EOF

for i in {1..1000}; do
  curl -s -H "Host: webapp.abhyas.local" http://127.0.0.1/ | head -n 1
done | sort | uniq -c