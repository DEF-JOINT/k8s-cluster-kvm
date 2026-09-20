#!/bin/bash
set -euo pipefail

VMS=(master1 worker1 worker2 worker3)

echo "Будут остановлены и удалены (undefine) следующие ВМ: ${VMS[*]}"
echo "Диски (qcow2/iso) при этом НЕ удаляются."
read -rp "Продолжить? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Отменено."
    exit 0
fi

for vm in "${VMS[@]}"; do
    if sudo virsh domstate "$vm" &>/dev/null; then
        if [ "$(sudo virsh domstate "$vm")" = "running" ]; then
            echo "==> Остановка $vm"
            sudo virsh destroy "$vm"
        fi
        echo "==> Удаление определения $vm"
        sudo virsh undefine "$vm"
    else
        echo "ВМ $vm не найдена, пропускаем"
    fi
done

echo "==> Готово."
