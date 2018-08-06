#!/bin/bash

echo "Running playbooks to prep bastion/jump station"
ansible-playbook -i hosts.jump -u root -l jump prep-os-for-bastion.yml --ask-vault-pass

