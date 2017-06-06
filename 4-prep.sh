#!/bin/bash
echo "Running playbooks to prep hosts"
ansible-playbook -i hosts -u root prep-os-for-ocp.yml
