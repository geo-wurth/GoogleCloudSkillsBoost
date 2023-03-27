#!/bin/bash
gcloud compute firewall-rules delete open-access --quiet
gcloud compute instances start bastion --zone us-east1-b
gcloud compute firewall-rules create allow-ssh-iap --action ALLOW --direction INGRESS --network acme-vpc --rules tcp:22 --source-ranges 35.235.240.0/20 --target-tags $FW_SSH_IAP_TAG
gcloud compute instances add-tags bastion --tags $FW_SSH_IAP_TAG --zone us-east1-b
gcloud compute firewall-rules create allow-http --action ALLOW --direction INGRESS --network acme-vpc --rules tcp:80 --source-ranges 0.0.0.0/0 --target-tags $FW_HTTP_TAG
gcloud compute instances add-tags juice-shop --tags $FW_HTTP_TAG --zone us-east1-b
gcloud compute firewall-rules create allow-ssh-internal --action ALLOW --direction INGRESS --network acme-vpc --rules tcp:22 --source-ranges 192.168.10.0/24 --target-tags $FW_SSH_INTERNAL_TAG
gcloud compute instances add-tags juice-shop --tags $FW_SSH_INTERNAL_TAG --zone us-east1-b
gcloud compute ssh bastion --tunnel-through-iap --zone us-east1-b --quiet --command "gcloud compute ssh juice-shop --internal-ip --zone us-east1-b --quiet"