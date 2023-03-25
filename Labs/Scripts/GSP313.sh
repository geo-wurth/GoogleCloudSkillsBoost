#!/bin/bash
gcloud compute instances create $VM_NAME \
    --machine-type=f1-micro \
    --zone=$ZONE
gcloud container clusters create cluster-backend \
    --machine-type=e2-medium \
    --zone=$ZONE
gcloud container clusters get-credentials cluster-backend \
    --zone=$ZONE
kubectl create deployment hello-server \
    --image=gcr.io/google-samples/hello-app:2.0
kubectl expose deployment hello-server \
    --type=LoadBalancer \
    --port=$APP_PORT
gcloud compute instance-templates create web-server-template \
    --region=$REGION \
    --network=default \
    --machine-type=e2-medium \
    --metadata startup-script='#! /bin/bash
        apt-get update
        apt-get install -y nginx
        service nginx start
        sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html'
gcloud compute instance-groups managed create web-server-group \
    --base-instance-name web-server \
    --size=2 \
    --template=web-server-template \
    --region=$REGION
gcloud compute instance-groups managed set-named-ports web-server-group \
    --named-ports=http:80 \
    --region=$REGION
gcloud compute firewall-rules create $FW_RULE_NAME \
    --allow tcp:80 \
    --network default
gcloud compute http-health-checks create http-basic-check
gcloud compute backend-services create web-server-backend \
    --protocol=HTTP \
    --http-health-checks=http-basic-check \
    --global
gcloud compute backend-services add-backend web-server-backend \
    --instance-group=web-server-group \
    --instance-group-region=$REGION \
    --global
gcloud compute url-maps create web-server-map \
    --default-service=web-server-backend
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-server-map
gcloud compute forwarding-rules create $FW_RULE_NAME \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80