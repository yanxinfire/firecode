#!/bin/bash
echo $1 > /etc/hostname
sed -i "/IPADDR/s/100/$2/" /etc/sysconfig/network-scripts/ifcfg-ens33
sed -i "/template/d"  /etc/hosts
for i in $(seq 101 $2)
do
  echo "192.168.12.$i     node$[$i-100]" >> /etc/hosts
done
ssh-keygen -f /root/.ssh/id_rsa -N "" &>/dev/null
