#!/bin/bash

# need to make sure these are in the right order
# - things won't delete if router/subnet/network are done
# in the wrong order, right?
os_components=("server" "volume" "router" "subnet" "network" "keypair" "security_group")
# made this a single line because doing it with \ got weird...
# - detected any extra spaces as array elements...

public_server_suffix="-headnode"

# Can't stick a variable in that brace expansion...
for user in train{0..50}; do
  source /home/$user/openrc.sh
  server_public_ip=$(openstack server list -f value -c Networks --name ${OS_USERNAME}${public_server_suffix} | sed 's/.*, //')
  echo "openstack floating ip release $server_public_ip"
  echo $OS_USERNAME
  for i in `seq 0 $((${#os_components[*]} - 1))`; do # I apologize.
    echo "Removing ${os_components[$i]} for $OS_USERNAME:"
    openstack ${os_components[$i]} list -f value -c Name | grep ${OS_USERNAME}
    particulars=$(openstack ${os_components[$i]} list -f value -c ID -c Name | grep $OS_USERNAME | cut -f 1 -d' ' | tr '\n' ' ') # this should grab head & computes
    for thing in $particulars; do
      echo "openstack ${os_components[$i]} delete $thing"
    done
  done

  ls /home/$user/openrc.sh
  ls /home/$user/${OS_USERNAME}-api-key*
  ls -rf /home/$user/.ssh 
  # anything else to delete?
done
