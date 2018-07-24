#!/bin/bash

source openrc.sh

openstack network create jecoulte-api-net
openstack subnet create --network jecoulte-api-net --subnet-range 10.0.0.0/24 jecoulte-api-subnet1
openstack subnet list
openstack router create jecoulte-api-router
openstack router add subnet jecoulte-api-router jecoulte-api-subnet1
openstack router set --external-gateway public jecoulte-api-router
openstack router show jecoulte-api-router
