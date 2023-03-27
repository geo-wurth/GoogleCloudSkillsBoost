#!/bin/bash
gcloud compute forwarding-rules create my-ilib-forwarding-rule --address my-ilb-ip --load-balancing-scheme INTERNAL --ip-version IPV4 --region us-central1 --backend-service my-ilib --ports 80 --network my-internal-app --subnet subnet-b
gcloud compute firewall-rules create app-allow-health-check --action ALLOW --rules tcp --source-ranges 130.211.0.0/22,35.191.0.0/16 --target-tags lb-backend
gcloud compute instance-templates create instance-template-1 --machine-type f1-micro --region us-central1 --network-interface network=my-internal-app,subnet=subnet-a --tags lb-backend --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh
gcloud compute instance-templates create instance-template-2 --machine-type f1-micro --region us-central1 --network-interface network=my-internal-app,subnet=subnet-b --tags lb-backend --metadata startup-script-url=gs://cloud-training/gcpnet/ilb/startup.sh
gcloud compute instance-groups managed create instance-group-1 --size 1 --zone us-central1-a --template instance-template-1
gcloud compute instance-groups managed set-autoscaling instance-group-1 --zone us-central1-a --cool-down-period 45 --min-num-replicas 1 --max-num-replicas 5 --scale-based-on-cpu --target-cpu-utilization 0.8
gcloud compute instance-groups managed create instance-group-2 --size 1 --zone us-central1-b --template instance-template-2
gcloud compute instance-groups managed set-autoscaling instance-group-2 --zone us-central1-b --cool-down-period 45 --min-num-replicas 1 --max-num-replicas 5 --scale-based-on-cpu --target-cpu-utilization 0.8
gcloud compute instances create utility-vm --zone 	us-central1-f --machine-type f1-micro --network-interface network=my-internal-app,subnet=subnet-a,private-network-ip=10.10.20.50
gcloud compute health-checks create tcp my-ilb-health-check --port 80 
gcloud compute backend-services create my-ilib --load-balancing-scheme INTERNAL --protocol TCP --health-checks my-ilb-health-check --region us-central1
gcloud compute backend-services add-backend my-ilib --instance-group instance-group-1 --instance-group-zone us-central1-a --region us-central1
gcloud compute backend-services add-backend my-ilib --instance-group instance-group-2 --instance-group-zone us-central1-b --region us-central1
gcloud compute addresses create my-ilb-ip --region us-central1 --subnet subnet-b --addresses 10.10.30.5
gcloud compute forwarding-rules create my-ilib-forwarding-rule --address my-ilb-ip --load-balancing-scheme INTERNAL --ip-version IPV4 --region us-central1 --backend-service my-ilib --ports 80 --network my-internal-app --subnet subnet-b