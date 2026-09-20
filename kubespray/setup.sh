#!/bin/bash
set -euo pipefail

KUBESPRAY_DIR="$HOME/kubespray"
KUBESPRAY_REPO="https://github.com/kubernetes-sigs/kubespray.git"
CLUSTER_NAME="mycluster"

echo "==> Установка системных зависимостей"
sudo apt update
sudo apt install -y python3 python3-pip python3-venv git

echo "==> Клонирование kubespray в $KUBESPRAY_DIR"
if [ -d "$KUBESPRAY_DIR" ]; then
    echo "Каталог $KUBESPRAY_DIR уже существует, пропускаем клонирование"
else
    git clone --depth 1 "$KUBESPRAY_REPO" "$KUBESPRAY_DIR"
fi

cd "$KUBESPRAY_DIR"

echo "==> Создание виртуального окружения"
python3 -m venv venv
source venv/bin/activate

echo "==> Установка Python-зависимостей"
pip install -U pip
pip install -r requirements.txt

echo "==> Подготовка инвентаря кластера: inventory/${CLUSTER_NAME}"
cp -rfp inventory/sample "inventory/${CLUSTER_NAME}"

echo "==> Готово."
echo "Дальше отредактируй inventory/${CLUSTER_NAME}/inventory.ini под свои ноды, затем:"
echo "  source ${KUBESPRAY_DIR}/venv/bin/activate"
echo "  ansible -i inventory/${CLUSTER_NAME}/inventory.ini -m ping all"
