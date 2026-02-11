#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

CANARY_INGRESS="web-app-ingress-canary"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <weight>"
    exit 1
fi

WEIGHT="$1"

if [[ "$WEIGHT" != "20" && "$WEIGHT" != "50" && "$WEIGHT" != "100" ]]; then
    echo "Weight should be 20, 50, or 100"
    exit 1
fi

cat <<EOF
Setting canary weight to ${WEIGHT}%...

kubectl annotate ingress ${CANARY_INGRESS} nginx.ingress.kubernetes.io/canary-weight=${WEIGHT} --overwrite

EOF

kubectl annotate ingress ${CANARY_INGRESS} \
    nginx.ingress.kubernetes.io/canary-weight=${WEIGHT} --overwrite

echo
cat <<EOF
Confirm Annotation:

kubectl describe ingress ${CANARY_INGRESS} | grep -i canary

EOF
kubectl describe ingress ${CANARY_INGRESS} | grep -i canary