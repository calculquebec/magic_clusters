#!/bin/bash

# Usage:
#	bash bump_version.sh 11.7 11.8
#	bash bump_version.sh 11.7 11.8 beluga
#	bash bump_version.sh 11.7 11.8 beluga/pyt101

from_ver=${1?Missing from version argument}
to_ver=${2?Missing to version argument}
path=${3-.}

# Go as deep as ./beluga/cip101/main.tf and no more.
for fname in $(find $path -maxdepth 3 -type f -name "main.tf");
do
	echo "Bumping version from $from_ver to $to_ver : $fname"
	sed -i -e "s#\"$from_ver\"#\"$to_ver\"#" \
	       -e "s#/cloudflare?ref=$from_ver#/cloudflare?ref=$to_ver#" \
	       -e "s#/openstack?ref=$from_ver#/openstack?ref=$to_ver#" "$fname"
done
