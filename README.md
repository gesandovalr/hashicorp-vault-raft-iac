# Hashicorp-vault-raft-iac

The following project aims to automate a hashicorp 3 node raft cluster with Azure-Keyvault as unsealer.

# Prerequisites

Have Azure keyvault setup previously with the following instructions this is for the autounseal procedure for the vault nodes.
https://andersonsleite.medium.com/deploy-hashicorp-vault-w-auto-unseal-using-azure-gitlab-and-kubernetes-integrated-241e888ac94e

# Vars setup

The file Ansible/Group_Vars/deploy_info has the following variables adjust them according to your needs.

    var_group:    
    node_01_ip_address: "1.1.1.1"
    node_02_ip_address: "2.2.2.2"
    node_03_ip_address: "3.3.3.3"
    keepalived_VIP_ip_address: "4.4.4.4"
    node_01_ip_address_dns: "ip-1-1-1-1"
    node_02_ip_address_dns: "ip-2-2-2-2"
    node_03_ip_address_dns: "ip-3-3-3-3"
    keepalived_VIP_ip_address_dns: "ip-4-4-4-4"
    node_01_short_name: "kvnode01"
    node_02_short_name: "kvnode02"
    node_03_short_name: "kvnode03"
    node_01_fqdn: "kvnode01.lab.local"
    node_02_fqdn: "kvnode02.lab.local"
    node_03_fqdn: "kvnode03.lab.local"
    domain_fqdn: "lab.local"
    hashicorp_cluster_name: "kvcluster01"
    hashicorp_cluster_name_fqdn: "kvcluster01.lab.local"
    interface_name: "eth0"

# Terraform and pipeline

This was done using GITLAB and KVM in a lab environment so please adjust your terraform template and pipeline configurations.

# Main Playbook

In the main playbook change the certificate authority host to your primary node.

    - hosts: kvnode01.lab.local ## <-- Change this for your primary node to install the certificate authority.
      become: true
      vars_files:
        - group_vars/deploy_info.yaml

# Disclaimer

I will not be held responsible for any damages or costs which might occur as a result of my advice or designs.
