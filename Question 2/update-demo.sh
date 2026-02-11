#!/usr/bin/env bash

set -o pipefail
set -o nounset
set -o errexit

DEPLOYMENT="web-app"
SERVICE="web-app-service"

echo "DEMO STARTS!!! :)))"
echo

echo
echo
echo "------ CURRENT STATE ------"
echo
cat <<EOF
kubectl get deployments "$DEPLOYMENT"
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
kubectl get svc "$SERVICE"
EOF
echo
kubectl get deployments "$DEPLOYMENT"
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
kubectl get svc "$SERVICE"
echo

echo
echo
echo "------ SERVICE ENDPOINT ------"
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

echo
echo
echo "------ Rolling update to nginx:1.29 ------"
echo
cat <<EOF
kubectl set image deploy/"$DEPLOYMENT" nginx=nginx:1.29
kubectl rollout status deploy/"$DEPLOYMENT" --watch=true
EOF
echo
kubectl set image deploy/"$DEPLOYMENT" nginx=nginx:1.29
kubectl rollout status deploy/"$DEPLOYMENT" --watch=true
echo

echo
echo
echo "------ After update ------"
echo
cat <<EOF
kubectl get rs
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
EOF
echo
kubectl get rs
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
echo

echo
echo
echo "------ Rollback ------"
echo
cat <<EOF
kubectl rollout undo deploy/"$DEPLOYMENT"
kubectl rollout status deploy/"$DEPLOYMENT" --watch=true
EOF
echo
kubectl rollout undo deploy/"$DEPLOYMENT"
kubectl rollout status deploy/"$DEPLOYMENT" --watch=true
echo

echo
echo
echo "------ After Rollback ------"
echo
cat <<EOF
kubectl get rs
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
EOF
echo
kubectl get rs
kubectl get pods -l app="$DEPLOYMENT" -o wide
kubectl describe deployments "$DEPLOYMENT" | grep -i image
echo

echo
echo
echo "DEMO OVER!! :)))"