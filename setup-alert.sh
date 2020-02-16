#!/bin/bash
exec 1> setup-alert.log 2>&1
set -x

grep : data.txt | sed s/:/=/g  > file.sh

source file.sh
if [ $newsetup == true ]; then
	bash newqueue.sh
       if [ $? == 0 ]; then
	     echo "queue creation successfull.Check status is console"
       else
	     echo "CFT creation failed.Check logs for queue create sqscreate.log"
	     exit 1
       fi       
fi

queue=`echo $queuename | sed s/,/" "/g`
metric=`echo $metric | sed s/,/" "/g`
echo $queue
count=1
for i in $queue
do
    echo $i
    for j in $metric 
      do
         sed  s/#queue#/$i/g rules.yml > rules.yml.$count
	 sed  -i s/#metric#/$j/g  rules.yml.$count
	 sed  -i s/#thresholdvalue#/$thresholdvalue/g  rules.yml.$count
         sed  -i s/#operator#/$operator/g rules.yml.$count
	 sed -i s/#severity#/$severity/g rules.yml.$count
	 sed -i s/#teamname#/$teamname/g rules.yml.$count
         count=`expr $count + 1`
      done

done
grep "receiver: $teamname" /etc/alertmanager/alertmanager.yaml

if [ $? != 0 ]; then
   sed  s/#teamname#/$teamname/g route.yml > route.$teamname.yml
   sed -i s/#teamemail#/$teamemail/g route.$teamname.yml
   line=$(grep -n 'receivers:' /etc/alertmanager/alertmanager.yaml | cut -d ":" -f 1) && { head -n $(($line-1)) /etc/alertmanager/alertmanager.yaml; cat route.$teamname.yml && echo ; tail -n +$line /etc/alertmanager/alertmanager.yaml; } > alert.yml && awk '/receivers/&&c++>0 {next} 1' alert.yml > /etc/alertmanager/alertmanager.yaml
fi

for f in rules.yml.*; do (cat "${f}"; echo " ") >> /etc/prometheus/alertrule.yml; done
   #cat rules.yml.* > rules.$teamname.yml
#clean up configs
   
rm rules.yml.*
rm alert.yml
rm route.*.yml

#Validate alertmanager config
 amtool check-config /etc/alertmanager/alertmanager.yaml
   if [ $? == 0 ]; then
	   echo "config looks ok"
   else
	   echo "something wrong with alertmanager config.please check /etc/alertmanager/alertmanager.yaml"
   fi

 promtool check rules /etc/prometheus/alertrule.yaml
   if [ $? == 0 ]; then
	   echo "proemtheus config looks ok"
   
   else
	   echo "something wrong with prometheus config.please check /etc/prometheus/prometheus.yaml"
   fi
  
   ## Reloading config for prometheus and alertmanager
   curl -X POST http://localhost:9090/-/reload  # prometheus config
   curl -X POST http://localhost:9093/-/reload  # alertmanager config
   
