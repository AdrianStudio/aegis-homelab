# ADR 0001: K3s VM layout on Proxmox

- **Status:** accepted
- **Date:** 2026-11-12

## Context

The cluster has three Proxmox nodes with local storage only (no shared storage). K3s will run as a three-server HA cluster with embedded etcd.

## Decision

- **One VM per physical node**, so losing one node keeps etcd quorum (2 of 3).
- **Each node clones its own template** (9000/9001/9002). A template on local storage can't be cloned to another node.
- **IPs 192.168.1.31–33.** The originally planned .201–.203 and .211–.213 clashed with existing LAN devices. They must stay outside the router's DHCP range.
- **VM IDs 301–303.** 201 is taken by Pi-hole.
- **Sizing:** 4 cores each; 6 GB on `proxmox` (it also runs DevBox, Pi-hole and the Discord bot), 8 GB on the workers; 50 GB disks.

## Consequences

- No live migration between nodes without shared storage; a failed node's VM is rebuilt, not moved.
- VMs are created by OpenTofu in `infrastructure/opentofu/proxmox`; configuration inside them is Ansible's job.
