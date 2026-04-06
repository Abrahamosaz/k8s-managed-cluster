## Kubernetes (kubeadm) via Ansible

This folder automates what your `install.sh`, `control_plane.sh`, and `worker_node.sh` scripts do:

- All nodes: disable swap, kernel modules, sysctl, containerd, Kubernetes apt repo, install `kubelet/kubeadm/kubectl`
- Control plane: `kubeadm init`, configure kubeconfig, install Calico, generate a join command
- Workers: run the join command (only if not already joined)

### Inventory

Edit `inventory/aws-ec2-hosts.ini` and put your hosts in:

- `master_node` (exactly 1 host recommended)
- `worker_node` (one or more hosts)

### Run

From this `ansible/` directory:

```bash
ansible-playbook -i inventory/aws-ec2-hosts.ini k8s-cluster.yaml
```

### Variables

You can override these at runtime with `-e`:

- `k8s_version_minor`: `v1.35` (default)
- `pod_network_cidr`: `192.168.0.0/16` (default)
- `calico_version`: `v3.31.4` (default)

