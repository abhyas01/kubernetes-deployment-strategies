#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

SERVICE="web-app-bg-svc"

echo "Running rollback script..."
echo

echo
echo
echo "Switching service selector back to blue (env=blue)"
echo
cat <<EOF
kubectl patch svc "$SERVICE" -p '{"spec":{"selector":{"app":"web-app","env":"blue"}}}'
EOF
echo
kubectl patch svc "$SERVICE" -p '{"spec":{"selector":{"app":"web-app","env":"blue"}}}'
echo

echo
echo
echo "Confirm if service selector now is for blue"
echo
cat <<EOF
kubectl describe svc "$SERVICE" | grep -i selector
EOF
echo
kubectl describe svc "$SERVICE" | grep -i selector
echo

echo
echo
echo "Confirm endpoints now point to BLUE pods"
echo
cat <<EOF
kubectl get endpointslices -l kubernetes.io/service-name="$SERVICE" -o wide
EOF
echo
kubectl get endpointslices -l kubernetes.io/service-name="$SERVICE" -o wide
echo

echo
echo
echo "Confirm if service is reachable"
echo
cat <<EOF
Port forwarding: (localhost:8080 -> port 80) of service/${SERVICE}

kubectl port-forward service/"$SERVICE" 8080:80 >/dev/null 2>&1 &
PID=\$!
sleep 2

Sleeping for 2 seconds....
EOF
kubectl port-forward service/"$SERVICE" 8080:80 >/dev/null 2>&1 &
PID=$!
sleep 2
echo
cat <<EOF
curl -i http://127.0.0.1:8080
kill \$PID 2>/dev/null || true
wait \$PID 2>/dev/null || true
EOF
echo
curl -i http://127.0.0.1:8080
kill $PID 2>/dev/null || true
wait $PID 2>/dev/null || true
echo