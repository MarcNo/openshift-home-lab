#!/bin/bash

echo "Running playbooks to prep openshift hosts"
ansible-playbook -i hosts -u root -l ocp prep-os-for-ocp.yml --ask-vault-pass
