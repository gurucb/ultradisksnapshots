#!/bin/bash
echo $HOME
sudo apt-get update
sudo apt -y -q=4 install jq
cat /etc/fstab | grep "prdvg"

if [[ ${?} -ne 0 ]]; then
	echo "Volume Group Not found"
	# Using Azure Instance Metadata Service
	curl -H Metadata:true --noproxy "*" "http://169.254.169.254/metadata/instance?api-version=2020-06-01" | jq . > GenMetadata.txt
	vm_gen=$(cat GenMetadata.txt | jq .compute.vmSize |tr -d '"' |awk -F_ '{print $3}')
	echo "VM Generation"
	echo $vm_gen
	if [[ $vm_gen ==  v4 ]]; then
		echo "Version V4"
		IGNORE="/dev/sda"
	else
		echo "Version V5"
		IGNORE="/dev/sda|/dev/sdb"
	fi
	echo  "List of default drives that will be ignored"
	echo ${IGNORE}
	drvs=($(ls /dev/sd* | egrep -v "${IGNORE}|[0-9]$"))
	echo "Volume Groups will be created with below disks"
	echo ${drvs[@]:1:5}
	vgcreate  -s 16M prdinstvg ${drvs[0]}
	lvcreate -n prd -l 100%FREE -i 1 -I 16M prdinstvg
	mkfs.ext4 /dev/prdinstvg/prd

	vgcreate -s 16M prdvg ${drvs[@]:1:4}
	lvcreate -n prd01 -l 100%FREE -i 4 -I 16M prdvg
	mkfs.ext4 /dev/prdvg/prd01

	vgcreate -s 16M prdwijvg ${drvs[5]}	
	lvcreate -n prdwij -l 100%FREE -i 1 -I 16M prdwijvg
	mkfs.ext4 /dev/prdwijvg/prdwij

	mkdir /epic
	chmod 755 /epic
	chown root:root /epic

	mkdir /epic/prd01
	chmod 755 /epic/prd01
	chown root:root /epic/prd01

	mkdir /epic/prd
	chmod 755 /epic/prd
	chown root:root /epic/prd

	mkdir /epic/prdwij
	chmod 755 /epic/prdwij
	chown root:root /epic/prdwij

	#echo '/dev/mapper/prdvg-prd01  /epic/prd01 ext4 nobarrier,nofail 0 0' > /etc/fstab
	#echo '/dev/mapper/prdinstvg-prd      /epic/prd ext4 nobarrier,nofail 0 0' > /etc/fstab
	#echo '/dev/mapper/prdwijvg-prdwij    /epic/prdwij    ext4 nobarrier,nofail 0 0' > /etc/fstab

fi
