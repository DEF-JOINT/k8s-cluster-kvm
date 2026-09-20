#!/bin/bash
set -euo pipefail

VM_BUILD_DIR="$HOME/vm-build"
IMAGES_DIR="/var/lib/libvirt/images/k8s"
WORKERS=(worker1 worker2 worker3)

cd "$VM_BUILD_DIR"

for name in "${WORKERS[@]}"; do
    NETWORK_CONFIG="configs/${name}-network-config.yaml"
    USER_DATA="configs/${name}-user-data.yaml"
    SEED_PATH="${IMAGES_DIR}/${name}-seed.iso"

    if [ ! -f "$NETWORK_CONFIG" ] || [ ! -f "$USER_DATA" ]; then
        echo "Конфиги для $name не найдены (нужны $NETWORK_CONFIG и $USER_DATA)" >&2
        exit 1
    fi

    echo "==> Генерация seed ISO для $name -> $SEED_PATH"
    sudo cloud-localds -N "$NETWORK_CONFIG" \
        "$SEED_PATH" \
        "$USER_DATA"
done

echo "==> Готово. Seed ISO созданы для: ${WORKERS[*]}"
