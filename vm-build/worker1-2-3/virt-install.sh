#!/bin/bash
set -euo pipefail

IMAGES_DIR="/var/lib/libvirt/images/k8s"
BRIDGE="br0"
OS_VARIANT="ubuntu22.04"
WORKER_MEMORY=6144      # MB
WORKER_VCPUS=2
WORKERS=(worker1 worker2 worker3)

for w in "${WORKERS[@]}"; do
    DISK_PATH="${IMAGES_DIR}/${w}.qcow2"
    SEED_PATH="${IMAGES_DIR}/${w}-seed.iso"

    if [ ! -f "$DISK_PATH" ] || [ ! -f "$SEED_PATH" ]; then
        echo "Диск или seed ISO для $w не найдены (нужны $DISK_PATH и $SEED_PATH)" >&2
        exit 1
    fi

    echo "==> Создание ВМ: $w"
    sudo virt-install \
        --name "$w" \
        --memory "$WORKER_MEMORY" --vcpus "$WORKER_VCPUS" \
        --cpu host-passthrough \
        --disk path="$DISK_PATH",bus=virtio \
        --disk path="$SEED_PATH",device=cdrom \
        --network bridge="$BRIDGE",model=virtio \
        --os-variant "$OS_VARIANT" \
        --import --graphics none --noautoconsole
done

echo "==> Готово. Созданы ВМ: ${WORKERS[*]}"
echo "Подключиться к консоли: sudo virsh console <имя_ноды>"
