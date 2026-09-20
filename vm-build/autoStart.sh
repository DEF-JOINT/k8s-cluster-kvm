#!/bin/bash
set -euo pipefail

VMS=(master1 worker1 worker2 worker3)

for vm in "${VMS[@]}"; do
    echo "==> Включение autostart для $vm"
    sudo virsh autostart "$vm"
done

echo "==> Готово. Autostart включен для: ${VMS[*]}"
