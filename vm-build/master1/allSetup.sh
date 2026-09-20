#!/bin/bash
set -euo pipefail

# ---- Параметры ВМ (меняй под конкретную ноду: master1, master2, worker1...) ----
VM_NAME="master1"
VM_MEMORY=8192          # MB
VM_VCPUS=4
VM_DISK_SIZE="40G"
BRIDGE="br0"
OS_VARIANT="ubuntu22.04"

IMAGES_DIR="/var/lib/libvirt/images/k8s"
CONFIGS_DIR="configs"
CLOUD_IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
CLOUD_IMAGE_FILE="jammy-server-cloudimg-amd64.img"

DISK_PATH="${IMAGES_DIR}/${VM_NAME}.qcow2"
SEED_PATH="${IMAGES_DIR}/${VM_NAME}-seed.iso"
NETWORK_CONFIG="${CONFIGS_DIR}/${VM_NAME}-network-config.yaml"
USER_DATA="${CONFIGS_DIR}/${VM_NAME}-user-data.yaml"

# ---- Скачивание базового образа (если ещё не скачан) ----
if [ ! -f "$CLOUD_IMAGE_FILE" ]; then
    echo "==> Скачивание базового образа Ubuntu Jammy"
    wget "$CLOUD_IMAGE_URL" -O "$CLOUD_IMAGE_FILE"
else
    echo "==> Базовый образ уже скачан, пропускаем"
fi

echo "==> Подготовка каталога образов"
sudo mkdir -p "$IMAGES_DIR"

echo "==> Копирование образа под диск ВМ: $DISK_PATH"
sudo cp "$CLOUD_IMAGE_FILE" "$DISK_PATH"

echo "==> Увеличение диска до ${VM_DISK_SIZE}"
sudo qemu-img resize "$DISK_PATH" "$VM_DISK_SIZE"

echo "==> Генерация cloud-init seed ISO: $SEED_PATH"
sudo cloud-localds -N "$NETWORK_CONFIG" \
    "$SEED_PATH" \
    "$USER_DATA"

echo "==> Создание ВМ: $VM_NAME"
sudo virt-install \
  --name "$VM_NAME" \
  --memory "$VM_MEMORY" --vcpus "$VM_VCPUS" \
  --cpu host-passthrough \
  --disk path="$DISK_PATH",bus=virtio \
  --disk path="$SEED_PATH",device=cdrom \
  --network bridge="$BRIDGE",model=virtio \
  --os-variant "$OS_VARIANT" \
  --import --graphics none --noautoconsole

echo "==> Готово. Подключиться к консоли: sudo virsh console $VM_NAME"
