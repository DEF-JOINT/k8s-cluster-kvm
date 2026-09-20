#!/bin/bash
set -euo pipefail

IMAGES_DIR="/var/lib/libvirt/images/k8s"
CLOUD_IMAGE_FILE="jammy-server-cloudimg-amd64.img"
DISK_SIZE="60G"
WORKERS=(worker1 worker2 worker3)

if [ ! -f "$CLOUD_IMAGE_FILE" ]; then
    echo "Базовый образ $CLOUD_IMAGE_FILE не найден в текущей директории" >&2
    exit 1
fi

sudo mkdir -p "$IMAGES_DIR"

for w in "${WORKERS[@]}"; do
    DISK_PATH="${IMAGES_DIR}/${w}.qcow2"
    echo "==> Копирование образа для $w -> $DISK_PATH"
    sudo cp "$CLOUD_IMAGE_FILE" "$DISK_PATH"

    echo "==> Увеличение диска $w до ${DISK_SIZE}"
    sudo qemu-img resize "$DISK_PATH" "$DISK_SIZE"
done

echo "==> Готово. Диски созданы: ${WORKERS[*]}"
