#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

GREEN_YAML="green-deployment.yaml"
GREEN_DEPLOY="web-app-green"
SERVICE="web-app-bg-svc"

echo "Running switch traffic script..."
echo

echo
echo
echo "Applying green deployment..."
echo
cat <<EOF
kubectl apply -f "$GREEN_YAML"
EOF
echo
kubectl apply -f "$GREEN_YAML"
echo

echo
echo
echo "Waiting for green rollout..."
echo
cat <<EOF
kubectl rollout status deploy/"$GREEN_DEPLOY"
EOF
echo
kubectl rollout status deploy/"$GREEN_DEPLOY"
echo

echo
echo
echo "Switching service selector to green (env=green)"
echo
cat <<EOF
kubectl patch svc "$SERVICE" -p '{"spec":{"selector":{"app":"web-app","env":"green"}}}'
EOF
echo
kubectl patch svc "$SERVICE" -p '{"spec":{"selector":{"app":"web-app","env":"green"}}}'
echo

echo
echo
echo "Confirm if service selector now is for Green"
echo
cat <<EOF
kubectl describe svc "$SERVICE" | grep -i selector
EOF
echo
kubectl describe svc "$SERVICE" | grep -i selector
echo

echo
echo
echo "Confirm endpoints now point to GREEN pods"
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