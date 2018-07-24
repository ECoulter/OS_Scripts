#!/bin/bash

source ./openrc.sh

if [[ -z "$1" ]]; then
  echo "NO SERVER NAME GIVEN! Please re-run with ./headnode_create.sh <server-name>"
  exit
fi

if [[ -z "$2" ]]; then
  echo "No instance size given - Setting default size to medium - for Matlab."
  server_size="m1.medium"
elif [[ "$2" =~ "m1" ]]; then
  echo "Using $2 as the server size directly"
  server_size=$2
else 
  echo "using m1.$2 as the server size!"
  server_size="m1.$2"
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

#image_name=$(openstack image list -f value | grep JS-API-Featured-Centos7 | grep -v Intel | cut -f 2 -d' ' )

image_name='1b47e0a2-0da0-42e4-95bb-08ccc10bf320'

openstack server create --flavor $server_size  --image $image_name --key-name jecoulte-key --security-group global-ssh --nic net-id=${OS_USERNAME}-api-net $1

new_ip=$(openstack floating ip create public | awk '/floating_ip_address/ {print $4}')

openstack server add floating ip $1 $new_ip

echo "Your new small instance is up at: $new_ip"
