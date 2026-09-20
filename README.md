# k8s-cluster-kvm
You can use a home computer that is currently sitting idle by installing Ubuntu Server on it and deploying your pet projects to hone your professional skills.

A KVM-based Kubernetes cluster consisting of one master node and three worker nodes. It includes the MetalLB load balancer for bare-metal deployment using Kubespray. This is a home project that you can adapt to your needs.

1) Installing KVM and libvirt, and configuring the network. The `enp3s0` interface serves as a raw port for the bridge. The IP address (192.168.0.190/24) and the default route are now assigned to `br0` rather than `enp3s0`. Note that we have bound the name `enp3s0` to a specific MAC address to prevent the interface from being renamed. We create the virtual network device `br0`—a software-based Layer 2 switch within the Linux kernel. Its purpose is to combine multiple interfaces into a single network segment where traffic flows at the MAC address level. Now, the bridge—not the physical network card—holds the IP address (192.168.0.190/24). When you connect virtual machines to this `br0` bridge, they appear on the network as distinct, fully functional devices with their own MAC and IP addresses—just as if they were physically plugged into the same switch as your host machine. Without the bridge, the VMs would only be visible via the host's NAT.

USE install-kvm.sh and sudo netplan apply (after editing network.conf)

2) After completing step 1, configure the nodes. Use `allSetup.sh` for `master1` (after first copying the configs to `~/configs/master1`) and the `*.sh` scripts in sequence for `workers1-3`. Refer to `master1` to determine the correct script execution order.

3) Run kubespray/setup.sh to prepare `kubespray`. Then, edit inventory.ini to ensure the correct deployment of K8s on the nodes.

4) Run metalLB/setup.sh to deploy `MetalLB`.

5) Enjoy yourself and create in your own home laboratory.
