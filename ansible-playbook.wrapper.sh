#!/bin/bash

# INFO:
# custom env variables:
# ANSIBLE_DONT_RUN - do not run ansible-playbook and exit 0 (success). Useful for dependent resource modificiation when runing ansible-playbook is not needed
# ANSIBLE_DRY_RUN  - run ansible-playbook with '--check --diff' options
#
# for example:
# ANSIBLE_DONT_RUN=1 terraform apply


#TODO: colors
#green
#blue
#red

export ANSIBLE_FORCE_COLOR=1
export ANSIBLE_HOST_KEY_CHECKING=0

if [ "$ANSIBLE_DONT_RUN" == "True" ]; then
  #TODO: add color for message (green,bold?)
  echo "DONT RUN"
  echo "ansible-playbook $@"
  echo "NOTE: modify a dependency (related inventory file) to run it again if needed"
  exit 0
fi

if [ "$ANSIBLE_DRY_RUN" == "True" ]; then
  #TODO: add color for message (blue,bold?)
  echo "DRY RUN"
  echo "NOTE: modify a dependency (related inventory file) to run it again if needed"
  ansible-playbook --check --diff $@
else
  #TODO: add color for message (red,bold?)
  echo "*********************"
  echo "*   NOT A DRY RUN   *"
  echo "*********************"
  ansible-playbook $@
fi

