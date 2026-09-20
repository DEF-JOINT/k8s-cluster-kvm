#!/bin/bash
set -euo pipefail

echo "==> Обновление списка пакетов"
sudo apt update

echo "==> Установка QEMU/KVM, libvirt и сопутствующих утилит"
sudo apt install -y \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virtinst \
    virt-manager \
    cpu-checker

echo "==> Проверка поддержки аппаратной виртуализации"
sudo kvm-ok

echo "==> Включение и запуск сервиса libvirtd"
sudo systemctl enable --now libvirtd

echo "==> Добавление пользователя $USER в группы libvirt и kvm"
sudo usermod -aG libvirt,kvm "$USER"
