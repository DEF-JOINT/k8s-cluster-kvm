#!/bin/bash
set -euo pipefail

# ---- Задай свой публичный SSH-ключ здесь ----
SSHKEY=""

mkdir -p configs

cat > configs/gen-cloudinit.sh << 'SCRIPT'
#!/bin/bash
set -euo pipefail

SSHKEY="__SSHKEY_PLACEHOLDER__"
GATEWAY="192.168.0.1"

declare -A HOSTS=(
  [master1]=192.168.0.11
  [worker1]=192.168.0.12
  [worker2]=192.168.0.13
  [worker3]=192.168.0.14
)

for name in "${!HOSTS[@]}"; do
  ip="${HOSTS[$name]}"

  cat > "configs/${name}-user-data.yaml" << EOF
#cloud-config
hostname: ${name}
manage_etc_hosts: true
users:
  - name: ansible
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - ${SSHKEY}
    shell: /bin/bash
package_update: true
packages:
  - qemu-guest-agent
  - open-iscsi
  - nfs-common
runcmd:
  - systemctl enable --now qemu-guest-agent
EOF

  cat > "configs/${name}-network-config.yaml" << EOF
version: 2
ethernets:
  enp1s0:
    addresses: [${ip}/24]
    gateway4: ${GATEWAY}
    nameservers:
      addresses: [8.8.8.8, 1.1.1.1]
EOF

  echo "Generated config for $name -> $ip"
done
SCRIPT

chmod +x configs/gen-cloudinit.sh
sed -i "s|__SSHKEY_PLACEHOLDER__|${SSHKEY}|" configs/gen-cloudinit.sh
./configs/gen-cloudinit.sh
