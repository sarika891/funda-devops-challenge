# funda-devops-challenge
funda-devops-challenge

As per the use case provided, i have created the small project which we can use to automate the monitoring of all the queues created by different team.
I have used prometheus/alertmanager along with sqs-exporter provided by prometheus to monitor the queue metrics.

## Assumptions:
1. Docker is pre installed.
2. OS: Ubuntu
3. awscli configured on the system wth proper rights to run cloud formation and creating queues in sqs.


## Installation:
1. Clone this project under your home directory
2. To run this we need to install **sqs exporter**, prometheus and alertmanager as below:
#### sqs-exporter: Run below command
  ```
	docker run -d -p 9384:9384 -e AWS_ACCESS_KEY_ID=<accesskey> -e AWS_SECRET_ACCESS_KEY=<secretkey> -e AWS_REGION=<regionname>  jmal98/sqs-exporter:0.0.7 
 ```
 
After running you can check in browser below url if its showing some metrics or not.
  **http://localhost:9384/metrics**
	
 #### Setup prometheus/alertmanager
 
Run **bash setup.sh** (some commands need sudo access so make sure you have proper permission prior to run this)
This script will do below:
1. Install prometheus and alertmanager
2. Create directories /etc/prometheus and /etc/alertmanager with default prometheus.yml,alertrules.yml and alertmanager.yml present under this github project
3. After script executed successfully you can check if you are able to reach prometheus and alertmanager as mentioned below.See description of default files.
   - Default prometheus.yml is configured to scrape metrics from sqs-exporter running on port 9384 and self metrics as well.
   - Default alertmanager.yml is configured with default receiver as devops team which receive all the alerts.
   - Default alertrules.tml is configured to monitor all the error queues(with error in the name) and send alerts to devops team.

**http://localhost:9090 :prometheus**  
**http://localhost:9093 :alertmanager**

## How it works:

1. We need to ask different teams to fill the data inside **_data.txt_** where we ask them to provide queuenames(support comma seperated list), metrics they want us to monitor(exposed by sqs-exporter) other specific alert informations.
2. After we get the information, we just need to run ```bash setup-alert.sh``` which do the following:
   - **Queue creation**: First it will check the paramter newsetup from *data.txt* which will decide whether we need to create the queue or not.I have created the small cft (**sqs-create.yml**) which create standard queues only for now.If this paramter is **true** then we will create the queues(by running newqueue.sh) by using default cft as template and wait for 30s to complete this step.
   - **Alert creation**: Once we are done with the queue creation we proceed and start creating alerts according to the configuration provided like if there are two queues defined and metric names are also there then it will create two alerts for one queue means in total 4 different alerts with other configurations like teamname,teamemail,threshold,operator.
       - For this we are using template files (rules.yml) and ( route.yml) which keeps on adding information as per the conmfiguration provided and finally merge all the rules and routes to main prometheus alert file and alertmanager alert file under /etc.
   - **Configuration check** : Once everything is done, we check the alertmanager configuration using **_amtool_** and **_promtool_** to see if everything looks ok if not script stops there and give error. On success we proceed and reload the config by sending POST request to reload api of alertmanager and prometheus using below:
   
**curl -X POST http://localhost:9090/-/reload  # prometheus config**

**curl -X POST http://localhost:9093/-/reload  # alertmanager config**

### On completion of above script you can see new alerts in prometheus and also new routes as well


_AlertManager config_ : Default wait time is 2m for each  alerts like if the alert stay for 2m then it will send a notification to team to take action.

# Error handling: 

1. newqueue.sh script will first check whether there is already stack created with the same name like sqs-$wueuename-create.yml, if yes    then it failed by giving the message else it proceed.
2. In alertmanager config we first check whether the team email or team name as receiver is already configured or not if its there then    we dont add it everytime.
3. Logging is enabled, two log file got created one is setup-alert.log(to log setup-alert.sh issues/log) and other is sqscreate.log (to log cft creation issue-newuqueue.sh).

**We can also create the grafana dashboard by using prometheus as datasource**


# Technologies and Tools Used:
bash scripting,aws commands to implement this automated solution,prometheus,alertmanager and sqs-exporter



**_I hope that this solution will cover all the requirements mentioned in the use case and also easy for team to just enter the information and we will manage the alerting for them.
The only **shortcoming** of this solution is that sqs exporter is only providing three metric as of now._**

## Other Solutions:
1. After  getting information from the team we can just create a cft and run it in aws using commandline and create queue,cloudwatch alarm and sns topic.
2. We can use cloudwatch exporter to export all the metrics from cloudwatch and then use prometheus to create alert over it.
