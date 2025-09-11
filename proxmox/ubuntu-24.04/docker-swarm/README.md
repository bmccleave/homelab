# Ansible Playbook: Docker Swarm Cluster with Keepalived VIP

This playbook provisions a three-node Docker Swarm cluster on clean Ubuntu 24.04 LTS VMs, configures a high-availability virtual IP (VIP) using keepalived, and deploys Portainer for cluster management.

## Target Hosts

- 192.168.1.221
- 192.168.1.222
- 192.168.1.223

> **Note:** This playbook is designed for these hosts but can be adapted for others by updating the inventory.

## Automated Steps

1. **Install Docker**  
   Installs Docker using the official apt instructions from [Docker Docs](https://docs.docker.com/engine/install/ubuntu).

2. **Configure Docker Group**  
   Adds the current user to the `docker` group for passwordless Docker commands.

3. **Initialize Docker Swarm**  
   Initializes the Swarm on `192.168.1.221` and retrieves the join token.

4. **Join Swarm Managers**  
   Joins `192.168.1.222` and `192.168.1.223` as Swarm managers using the token.

5. **Label Swarm Nodes**  
   - `192.168.1.221`: `node.labels.worker.group=primary`
   - `192.168.1.222`: `node.labels.worker.group=secondary`
   - `192.168.1.223`: `node.labels.worker.group=tertiary`

6. **Configure Keepalived**  
   Sets up keepalived on all nodes with:
   - VIP: `192.168.1.224`
   - Health check: Ensures keepalived only assigns VIP if Docker is active.
   - `virtual_router_id` and `auth_pass` are configurable via Ansible variables.

7. **Deploy Portainer**  
   On `192.168.1.221`, deploys Portainer as a Docker service for Swarm management.

## Usage Instructions

### 1. Update Inventory

Edit `inventory/hosts.ini` to match your target hosts.

### 2. Set Variables

Edit `group_vars/all.yml` to set:
- `keepalived_virtual_router_id`
- `keepalived_auth_pass`
- (Optional) Other Docker or keepalived settings

### 3. Prepare SSH Access

Ensure you can SSH into all nodes as a user with sudo privileges.

### 4. Run the Playbook

From the `docker-swarm` directory, run:

```powershell
ansible-galaxy install -r requirements.yml  # If you have external roles
ansible-playbook -i inventory/hosts.ini site.yml
```

> **Tip:** If running from WSL or a non-root user, you may need to add `--ask-become-pass` for privilege escalation.

### 5. Access Portainer

Once complete, access Portainer at:  
`http://192.168.1.224:9000`

---

## Customization

- To change the VIP, update the `keepalived_vip` variable in `group_vars/all.yml`.
- To add more nodes, update the inventory and adjust node labels as needed.

---

## References

- [Docker Swarm Overview](https://docs.docker.com/engine/swarm/swarm-overview/)
- [Keepalived Documentation](http://www.keepalived.org/documentation.html)
- [Portainer Documentation](https://docs.portainer.io/v2.0/start/quickstart)

---

## Troubleshooting

- **Docker Installation Issues:** Ensure the target Ubuntu version is 24.04 LTS and has internet access.
- **Swarm Join Issues:** Verify the join token and ensure no firewall is blocking communication between nodes.
- **Keepalived Issues:** Check keepalived logs for errors related to `virtual_router_id` or `auth_pass`.

---

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.

---

## License

This playbook is licensed under the MIT License. See the LICENSE file for details.

---
