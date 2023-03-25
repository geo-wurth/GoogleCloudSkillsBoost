#!/bin/bash
gcloud compute firewall-rules create default-allow-http --action ALLOW --rules tcp:80 --source-ranges 0.0.0.0/0 --target-tags http-server
gcloud compute firewall-rules create default-allow-health-check --action ALLOW --source-ranges 130.211.0.0/22,35.191.0.0/16 --rules tcp --target-tags http-server
gcloud compute instance-templates create $REGION'-template' --region $REGION --machine-type e2-micro --tags http-server --subnet default --metadata startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh
gcloud compute instance-templates create europe-west1-template --region europe-west1 --machine-type e2-micro --tags http-server --subnet default --metadata startup-script-url=gs://cloud-training/gcpnet/httplb/startup.sh
gcloud compute instance-groups managed create $REGION'-mig' --size 1 --region $REGION --template $REGION'-template' --target-distribution-shape EVEN
gcloud compute instance-groups managed set-autoscaling $REGION'-mig' --region $REGION --cool-down-period 45 --min-num-replicas 1 --max-num-replicas 2 --scale-based-on-cpu --target-cpu-utilization 0.8
gcloud compute instance-groups managed create europe-west1-mig --size 1 --region europe-west1 --template europe-west1-template --target-distribution-shape EVEN
gcloud compute instance-groups managed set-autoscaling europe-west1-mig --region europe-west1 --cool-down-period 45 --min-num-replicas 1 --max-num-replicas 2 --scale-based-on-cpu --target-cpu-utilization 0.8
gcloud compute health-checks create tcp http-health-check --port 80 --enable-logging
gcloud compute backend-services create http-backend --load-balancing-scheme EXTERNAL_MANAGED --protocol HTTP --port-name http --health-checks http-health-check --global
gcloud compute backend-services add-backend http-backend --instance-group $REGION'-mig' --instance-group-region $REGION --balancing-mode RATE --max-rate-per-instance 50 --global
gcloud compute backend-services add-backend http-backend --instance-group europe-west1-mig --instance-group-region europe-west1 --balancing-mode UTILIZATION --max-utilization 0.8 --global
gcloud compute url-maps create web-server-map --default-service http-backend
gcloud compute target-http-proxies create http-lb-proxy --url-map web-server-map
gcloud compute forwarding-rules create http-content-rule-ipv4 --load-balancing-scheme EXTERNAL_MANAGED --ip-version IPV4 --global --target-http-proxy http-lb-proxy --ports 80
gcloud compute forwarding-rules create http-content-rule-ipv6 --load-balancing-scheme EXTERNAL_MANAGED --ip-version IPV6 --global --target-http-proxy http-lb-proxy --ports 80
gcloud compute instances create siege-vm --zone $(gcloud compute zones list --filter region:$REGION --format 'value(NAME)' | head -n 1) --machine-type e2-medium --metadata startup-script='#!/bin/bash
        apt-get update
        apt-get -y install siege'
gcloud compute security-policies create denylist-siege
gcloud compute security-policies rules create 1000 --security-policy denylist-siege --src-ip-ranges $(gcloud compute instances list --filter name:'siege-vm' --format 'value(EXTERNAL_IP)') --action "deny-403"