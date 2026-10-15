
![Status](https://img.shields.io/badge/Status-In%20Progress-orange)
![Proxmox](https://img.shields.io/badge/Virtualization-Proxmox-E57000?logo=proxmox)
![OpenTofu](https://img.shields.io/badge/IaC-OpenTofu-FFDA18?logo=opentofu&logoColor=black)
![Ansible](https://img.shields.io/badge/Automation-Ansible-EE0000?logo=ansible&logoColor=white)
![K3s](https://img.shields.io/badge/Kubernetes-K3s-FFC61C?logo=k3s&logoColor=black)
![Ubuntu](https://img.shields.io/badge/OS-Ubuntu%20Server%2024.04-E95420?logo=ubuntu&logoColor=white)
![GitHub](https://img.shields.io/badge/Version%20Control-GitHub-181717?logo=github)

# AEGIS — Homelab Infrastructure & SRE Platform

A self-hosted infrastructure platform built to explore infrastructure as code, configuration management, Kubernetes, observability, and Site Reliability Engineering.

The goal is to build a reproducible environment on physical hardware, automate infrastructure operations, and progressively introduce monitoring and AI-assisted incident response.

This is not just a collection of services running in a homelab. It is an engineering project focused on understanding how infrastructure is provisioned, operated, monitored, recovered, and improved.

---

## Objectives

- **Infrastructure as Code:** provision virtual machines on Proxmox using OpenTofu.
- **Configuration Management:** automate operating system setup and cluster prerequisites with Ansible.
- **Container Orchestration:** build a highly available K3s cluster with three server nodes and embedded etcd.
- **Observability:** introduce metrics, monitoring, alerting, and incident tracking.
- **GitOps & CI/CD:** establish version-controlled infrastructure and workload delivery workflows.
- **SRE Automation:** develop a Python-based agent that analyses incidents and recommends safe remediation actions.
- **Reliability Engineering:** document failure scenarios, backup strategies, recovery procedures, and operational trade-offs.

---

## Architecture

The platform is designed around three physical Proxmox nodes. Each Kubernetes server will run in its own virtual machine, keeping the Kubernetes control plane distributed across the physical hosts.

```text
                         DEVELOPER
                             |
                       Git + GitHub
                             |
                  OpenTofu + Ansible
                             |
                    PROXMOX CLUSTER
             +---------------+---------------+
             |               |               |
         pve-master      pve-worker1     pve-worker2
             |               |               |
          k3s-01           k3s-02          k3s-03
             +---------------+---------------+
                             |
                  K3s HA Control Plane
                    Embedded etcd
                             |
             +---------------+----------------+
             |               |                |
          Workloads      Observability      GitOps
             |               |                |
             +---------------+----------------+
                             |
                    Future SRE Agent
                   Python + Telegram
```

The diagram represents the target architecture. Kubernetes, GitOps, observability, and SRE automation will be marked operational only after deployment and validation.

---

## Homelab Infrastructure

The physical infrastructure consists of three Proxmox nodes with a combined 48 GB of RAM.

| Node | Hardware | CPU | RAM |
|---|---|---|---|
| `pve-master` | HP EliteDesk 600 G2 SFF | Intel Core i5-6500 | 16 GB |
| `pve-worker1` | HP ProDesk 400 G3 Mini | Intel Core i5-7500T | 16 GB |
| `pve-worker2` | HP ProDesk 400 G3 Mini | Intel Core i5-7500T | 16 GB |

### Storage strategy

- Local SSD/NVMe storage will host the Kubernetes virtual machines.
- The NAS will be reserved for suitable storage and backup workloads.
- Kubernetes etcd will use local VM disks rather than depend on NAS storage.
- Backup and recovery procedures will be documented and tested as the platform evolves.

---

## Technology Stack

| Layer | Technology | Purpose | Status |
|---|---|---|---|
| Virtualization | Proxmox VE | VM provisioning and host management | Operational |
| Infrastructure as Code | OpenTofu | Declarative infrastructure provisioning | Installed |
| Configuration Management | Ansible | OS configuration and automation | Installed |
| Operating System | Ubuntu Server 24.04 LTS | Kubernetes VM operating system | Planned |
| Container Orchestration | K3s | Lightweight Kubernetes distribution | Planned |
| Cluster Datastore | Embedded etcd | Kubernetes state and consensus | Planned |
| Version Control | Git + GitHub | Source control and documentation | Operational |
| CI/CD | GitLab CI/CD | Automated validation and workflows | Planned |
| GitOps | Argo CD | Declarative workload delivery | Planned |
| Monitoring | Prometheus + Zabbix | Metrics, monitoring, and alerting | Planned |
| Secrets Management | HashiCorp Vault | Centralised secrets management | Planned |
| SRE Automation | Python | Incident analysis and remediation workflows | Planned |
| Notifications | Telegram Bot | Incident notifications and interaction | Planned |

---

## Infrastructure as Code

OpenTofu and Ansible have separate responsibilities.

### OpenTofu

OpenTofu will define and provision the virtual machines on Proxmox, including their compute resources, storage, networking, and lifecycle.

Infrastructure changes will be reviewed through plans before they are applied.

### Ansible

Ansible will configure the operating system and prepare each VM for Kubernetes.

Responsibilities will include:

- System packages and updates.
- Hostnames and network configuration.
- Kubernetes prerequisites.
- Consistent configuration across all three nodes.
- Repeatable execution and validation.

The objective is to make infrastructure reproducible rather than dependent on undocumented manual configuration.

---

## Kubernetes Design

The target platform uses three K3s server nodes with embedded etcd.

| Node | Planned IP | Physical Host |
|---|---|---|
| `k3s-01` | `192.168.1.201` | `pve-master` |
| `k3s-02` | `192.168.1.202` | `pve-worker1` |
| `k3s-03` | `192.168.1.203` | `pve-worker2` |

Planned network configuration:

| Setting | Value |
|---|---|
| LAN | `192.168.1.0/24` |
| Gateway | `192.168.1.1` |
| DNS | `192.168.1.200` |
| Pod CIDR | `10.42.0.0/16` |
| Service CIDR | `10.43.0.0/16` |

These are the current planned addresses and network ranges. VM resource allocations and connectivity will be validated before deployment.

### Why three server nodes?

Three etcd members provide quorum-based operation and allow the cluster to tolerate one member failure, provided the remaining members retain quorum and the necessary network connectivity.

This improves control-plane availability, but it does not automatically provide full application high availability. Workload replicas, persistent storage, backups, and recovery procedures must be designed separately.

---

## Observability & SRE

Monitoring will be introduced before enabling automated remediation.

The planned observability stack includes Prometheus and Zabbix for metrics, monitoring, and alerting. A Python-based SRE agent will later consume operational signals and help analyse incidents.

The agent will evolve incrementally:

1. Collect and correlate operational signals.
2. Identify anomalies and potential incidents.
3. Recommend remediation actions.
4. Execute explicitly permitted actions only after the safety controls have been implemented and validated.

The design will include action allowlists and denylists, audit logs, incident history, and notifications through Telegram.

The initial objective is reliable recommendations, not unrestricted autonomous access to the infrastructure.

---

## Security & Reliability Principles

- **Least privilege:** automation should receive only the permissions it needs.
- **Secrets management:** credentials and private keys must never be committed to Git.
- **Reviewable changes:** infrastructure modifications should be planned and version-controlled.
- **Observability first:** establish visibility before introducing automated remediation.
- **Recoverability:** backups are only useful when restoration has been tested.
- **Controlled automation:** remediation actions must have explicit permissions and an audit trail.
- **Failure isolation:** supporting services should remain accessible where practical when the Kubernetes platform is unavailable.

---

## Repository Structure

```text
aegis-homelab/
├── infrastructure/
│   ├── opentofu/       # Proxmox infrastructure definitions
│   └── ansible/        # OS configuration and automation
├── kubernetes/         # Kubernetes manifests and workloads
├── docs/               # Architecture and operational documentation
├── .gitignore
└── README.md
```

The Python virtual environment used by the development tools remains local and is excluded from version control.

OpenTofu state files, generated plans, variable files containing sensitive values, and credentials must also remain out of the public repository.

---

## Roadmap

- [x] Prepare the DevBox and install OpenTofu and Ansible.
- [x] Create the initial Git repository and publish it on GitHub.
- [x] Establish the initial repository structure and `.gitignore`.
- [ ] Finalise VM resource allocations.
- [ ] Provision three Kubernetes VMs with OpenTofu.
- [ ] Configure Ubuntu and Kubernetes prerequisites with Ansible.
- [ ] Deploy K3s and validate embedded etcd health.
- [ ] Implement and test backup and recovery procedures.
- [ ] Deploy monitoring and alerting.
- [ ] Introduce GitOps with Argo CD.
- [ ] Implement CI/CD workflows.
- [ ] Deploy secrets management.
- [ ] Build the SRE agent with recommendation-first incident handling.
- [ ] Add controlled remediation and incident auditing.

---

## Engineering Principles

- Reproducible infrastructure over undocumented manual changes.
- Declarative configuration over configuration drift.
- Small, validated changes over large deployments.
- Explicit trade-offs over unnecessary complexity.
- Tested recovery over assumed resilience.
- Measurable reliability over assumptions.
- Documented operational learning over simply getting services running.

---

## Current Status

AEGIS is under active development.

The three-node Proxmox environment is operational, and the DevBox has OpenTofu and Ansible installed. The GitHub repository and initial project structure are in place.

The Kubernetes cluster, monitoring stack, GitOps workflows, secrets management, and SRE agent remain planned work.

This README will evolve alongside the implementation, with architecture decisions, deployment evidence, validation results, and operational lessons documented as the platform grows.
