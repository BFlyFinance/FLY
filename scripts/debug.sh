#!/usr/bin/env sh
if [ $# != 1 ]; then
  echo 'input file filter'
  exit 1
fi
file=$1
echo $file
move clean && move check && move publish --ignore-breaking-changes && move functional-test $file