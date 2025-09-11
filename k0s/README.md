# Using k0sctl to Manage Your k0s Cluster

This guide explains how to use `k0sctl` with the provided configuration files to deploy and manage your k0s cluster.

## Prerequisites

- [k0sctl](https://docs.k0sproject.io/stable/k0sctl-install/) installed on your local machine.
- SSH access to all target nodes, with the correct private key available.
- The nodes must be accessible from your control machine.

## Files

- `k0sctl.yaml`: Main configuration for your home lab cluster (3 nodes, all controller+worker).
- `test.yaml`: Example configuration for a test cluster (2 controllers).

## Usage

### 1. Review and Edit the Config

- Open `k0sctl.yaml` (or `test.yaml`) and ensure:
  - The `address`, `user`, and `keyPath` fields are correct for your environment.
  - The SSH key specified in `keyPath` is the private key (not the public `.pub` file).
    - Example: `keyPath: ~/.ssh/id_ecdsa` (not `id_ecdsa.pub`).

### 2. Run k0sctl

From the directory containing your config file, run:

```bash
k0sctl apply --config k0sctl.yaml
```
or for the test cluster:
```bash
k0sctl apply --config test.yaml
```

- This will connect to each node, install k0s, and configure the cluster as described in the YAML file.

### 3. Cluster Management

- To check the status of your cluster:
  ```bash
  k0sctl kubeconfig --config k0sctl.yaml
  ```
- To upgrade or reconfigure, edit the YAML and re-run `k0sctl apply`.

## Notes

- Ensure your SSH key has the correct permissions and is not password-protected, or use an SSH agent.
- The user specified must have passwordless sudo privileges on the target nodes.
- If you encounter SSH or permission errors, verify connectivity and key configuration.

## References

- [k0sctl Documentation](https://docs.k0sproject.io/stable/k0sctl/)
- [k0s Documentation](https://docs.k0sproject.io/)

---
```# Using k0sctl to Manage Your k0s Cluster

This guide explains how to use `k0sctl` with the provided configuration files to deploy and manage your k0s cluster.

## Prerequisites

- [k0sctl](https://docs.k0sproject.io/stable/k0sctl-install/) installed on your local machine.
- SSH access to all target nodes, with the correct private key available.
- The nodes must be accessible from your control machine.

## Files

- `k0sctl.yaml`: Main configuration for your home lab cluster (3 nodes, all controller+worker).
- `test.yaml`: Example configuration for a test cluster (2 controllers).

## Usage

### 1. Review and Edit the Config

- Open `k0sctl.yaml` (or `test.yaml`) and ensure:
  - The `address`, `user`, and `keyPath` fields are correct for your environment.
  - The SSH key specified in `keyPath` is the private key (not the public `.pub` file).
    - Example: `keyPath: ~/.ssh/id_ecdsa` (not `id_ecdsa.pub`).

### 2. Run k0sctl

From the directory containing your config file, run:

```bash
k0sctl apply --config k0sctl.yaml
```
or for the test cluster:
```bash
k0sctl apply --config test.yaml
```

- This will connect to each node, install k0s, and configure the cluster as described in the YAML file.

### 3. Cluster Management

- To check the status of your cluster:
  ```bash
  k0sctl kubeconfig --config k0sctl.yaml
  ```
- To upgrade or reconfigure, edit the YAML and re-run `k0sctl apply`.

## Notes

- Ensure your SSH key has the correct permissions and is not password-protected, or use an SSH agent.
- The user specified must have passwordless sudo privileges on the target nodes.
- If you encounter SSH or permission errors, verify connectivity and key configuration.

## References

- [k0sctl Documentation](https://docs.k0sproject.io/stable/k0sctl/)