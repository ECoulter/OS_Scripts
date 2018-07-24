#!/bin/bash

if [[ -z "$1" ]]; then
  echo "NO openrc.sh given! Please re-run with ./headnode_create.sh <openrc-name> <server-name>"
  exit
fi

source ./$1

if [[ -z "$2" ]]; then
  echo "NO SERVER NAME GIVEN! Please re-run with ./headnode_create.sh <openrc-name> <server-name>"
  exit
fi


if [[ -z "$3" ]]; then
  echo "No instance size given - Setting default size to small."
  server_size="m1.small"
elif [[ "$3" =~ "m1" ]]; then
  echo "Using $3 as the server size directly"
  server_size=$3
else 
  echo "using m1.$3 as the server size!"
  server_size="m1.$3"
fi

if [[ -z "$(openstack network list | grep ${OS_USERNAME}-api-net)" ]]; then
  openstack network create ${OS_USERNAME}-api-net
  openstack subnet create --network ${OS_USERNAME}-api-net --subnet-range 10.0.0.0/24 ${OS_USERNAME}-api-subnet1
fi
if [[ -z "$(openstack router list | grep ${OS_USERNAME}-api-router)" ]]; then
  openstack router create ${OS_USERNAME}-api-router
  openstack router add subnet ${OS_USERNAME}-api-router ${OS_USERNAME}-api-subnet1
  openstack router set --external-gateway public ${OS_USERNAME}-api-router
fi

image_name=$(openstack image list -f value | grep -i JS-API-Featured-Centos7 | grep -v Intel | cut -f 2 -d' ' | head -n 1 )

echo "openstack server create --flavor $server_size  --image $image_name --key-name jecoulte-key --security-group global-ssh --nic net-id=${OS_USERNAME}-api-net $2"
openstack server create --flavor $server_size  --image $image_name --key-name jecoulte-key --security-group global-ssh --nic net-id=${OS_USERNAME}-api-net $2

new_ip=$(openstack floating ip create public | awk '/floating_ip_address/ {print $4}')
openstack server add floating ip $2 $new_ip

echo "Your new small instance is up at: $new_ip"
