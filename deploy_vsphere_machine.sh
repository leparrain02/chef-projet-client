#!/bin/bash

if [[ $# -ne 2 ]]; then
  echo "Usage: `basename $0` <machine_name> <template>"
  exit 1
fi

machine_name=$1
template=$2

spec="spec_linux"
datastore="SAN_LUN3"
template_folder="Templates"
vm_folder="Chef"
vm_user="root"
vm_password="qwerty"
hostname="${machine_name}.collegemultihexa.ca"
vlan="UAT_VLAN30"

knife vsphere vm clone ${machine_name} --template ${template} -f ${template_folder} --cips dhcp --cspec ${spec} --ssh-user ${vm_user} --ssh-password ${vm_password} --cvlan ${vlan} --datastore ${datastore} --dest-folder ${vm_folder} --start --bootstrap
