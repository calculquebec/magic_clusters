#!/bin/bash

# Usage:
#	bash update_email.sh <your email>
#	bash update_email.sh <your email> beluga
#	bash update_email.sh <your email> beluga/pyt101

your_email=${1?Missing your email argument}

# Go as deep as ./beluga/cip101/main.tf and no more.
for fname in $(find . -maxdepth 3 -mindepth 2 -type f -name "main.tf");
do
	echo "Updating email : $fname"
	sed -i -e "s#\"YOUR EMAIL\"#\"$your_email\"#" "$fname"
done
