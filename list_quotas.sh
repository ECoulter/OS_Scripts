#!/bin/bash

source ./openrc.sh

for project in $(cat my_projects.txt);
do
  export OS_PROJECT_NAME=$project
  echo "Quotas for project $project"
  openstack quota show -c cores -c ram -c instances
done
