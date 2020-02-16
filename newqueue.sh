#!/bin/bash

exec 1> sqscreate.log 2>&1
set -x

grep : data.txt | sed s/:/=/g  > file.sh
source file.sh
queue=`echo $queuename | sed s/,/" "/g`
echo $queue
count=1
for i in $queue
do
    echo $i
    if [ $newsetup == true ]; then
	  echo "creating new queue"
	  sed  s/#queuename#/$i/g sqs-cft.yml > sqs-cft.$i.yml
	  #check if there is any existing stack with the same name present
	  j=$i
	  i=`echo $i | sed s/_/-/g` #fixing stack name contraints
	  `aws cloudformation describe-stacks --stack-name $i-sqs-create`
	  if [ $? != 0 ]; then
             echo "Creating queue"
	     `aws cloudformation create-stack --stack-name $i-sqs-create --template-body file://sqs-cft.$j.yml`
              sleep 20s
           else
		echo "CFT with the same name already exists"  
		exit 1
          fi		
     fi
     #cleaning up files
     rm sqs-cft.*.yml
done
