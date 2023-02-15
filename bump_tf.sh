#!/bin/bash

# Usage:
#	bash bump_tf.sh 0.14.2 1.1.0
#	bash bump_tf.sh 0.14.2 1.1.0 beluga
#	bash bump_tf.sh 0.14.2 1.1.0 beluga/pyt101

from_ver=${1?Missing from version argument}
to_ver=${2?Missing to version argument}
path=${3-.}

# Go as deep as ./beluga/cip101/main.tf and no more.
for fname in $(find $path -maxdepth 3 -type f -name "main.tf");
do
	echo "Bumping TF version from $from_ver to $to_ver : $fname"
	sed -i -e "s#>= $from_ver#>= $to_ver#" "$fname"
done
