#!/bin/bash

# Usage:
#	bash bump_image.sh Rocky-8.7-x64-2023-02
#	bash bump_image.sh Rocky-8.7-x64-2023-02 beluga
#	bash bump_image.sh Rocky-8.7-x64-2023-02 beluga/pyt101

to_ver=${1?Missing to version argument}
path=${2-.}

# Go as deep as ./beluga/cip101/main.tf and no more.
for fname in $(find $path -maxdepth 3 -type f -name "main.tf");
do
	echo "Bumping image to $to_ver : $fname"
	sed -i -e "s/\"Rocky-.*\"/\"$to_ver\"/" "$fname"
done
