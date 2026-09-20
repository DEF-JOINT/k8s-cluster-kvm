#!/bin/bash
set -euo pipefail

METALLB_VERSION="v0.14.8"
METALLB_MANIFEST="https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml"
CONFIG_FILE="$HOME/metallb-config.yaml"
POOL_RANGE="192.168.0.220-192.168.0.250"

echo "==> Установка MetalLB $METALLB_VERSION"
kubectl apply -f "$METALLB_MANIFEST"

echo "==> Ожидание готовности подов MetalLB"
kubectl -n metallb-system wait --for=condition=ready pod \
    --selector=app=metallb \
    --timeout=180s

echo "==> Генерация конфига IPAddressPool/L2Advertisement: $CONFIG_FILE"
cat > "$CONFIG_FILE" << EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: home-pool
  namespace: metallb-system
spec:
  addresses:
    - ${POOL_RANGE}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2-adv
  namespace: metallb-system
spec:
  ipAddressPools:
    - home-pool
EOF

echo "==> Применение конфига"
kubectl apply -f "$CONFIG_FILE"

echo "==> Готово. Проверить: kubectl get ipaddresspools,l2advertisements -n metallb-system"
