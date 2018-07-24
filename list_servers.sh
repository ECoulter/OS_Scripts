#!/bin/bash

source ./openrc.sh

for project in $(cat my_projects.txt);
do
  export OS_PROJECT_NAME=$project
  openstack server list
done
