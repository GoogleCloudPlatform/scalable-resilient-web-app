#!/bin/bash
set -e
DEMO_PROJECT=demo-$(date +%s)
DB_NAME=$DEMO_PROJECT-db
DB_PW=$(cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)

# Create the instance
gcloud sql instances create ${DB_NAME} \
  --assign-ip \
  --authorized-networks "0.0.0.0/0" \
  --gce-zone us-central1-f \
  --pricing-plan PACKAGE \
  --require-ssl \
  --replication SYNCHRONOUS \
  --quiet \
  --tier D1

gcloud sql instances set-root-password ${DB_NAME} --password ${DB_PW}

# Get info about the new instance
DB_INSTANCE_ID=$(gcloud sql instances describe ${DB_NAME} | grep ^instance: | cut -d' ' -f2)
DB_INSTANCE_ADDR=$(gcloud sql instances describe ${DB_NAME} | grep ipAddress: | cut -d' ' -f3)


# Set vals in the Deployment Manager manifest
sed -i.bak "s/dbname:.*$/dbname: ${DB_INSTANCE_ID}/g" dm/deployment.yaml
sed -i.bak "s/address:.*$/address: ${DB_INSTANCE_ADDR}/g" dm/deployment.yaml
sed -i.bak "s/password:.*$/password: ${DB_PW}/g" dm/deployment.yaml
rm dm/*.bak

# Create the deployment
gcloud deployment-manager deployments \
    create ${DEMO_PROJECT} \
    --config dm/deployment.yaml

# Get the forwarding rule ID, then its address
FORWARDING_RULE=$(gcloud deployment-manager deployments describe ${DEMO_PROJECT} | grep compute.v1.globalForwardingRule | cut -d' ' -f 1)
APP_URL=http://$(gcloud compute forwarding-rules describe ${FORWARDING_RULE} --global | grep IPAddress | cut -f2 -d' ')

echo "Trying to access app at $APP_URL"
MINUTES=20
# Wait 20 minutes for app to become available
until $(curl --output /dev/null --silent --head --fail $APP_URL)
do
    echo "Waiting ${MINUTES} more minutes for application to become available at $APP_URL"
    MINUTES=$((MINUTES-1))
    if [ "${MINUTES}" = "0" ]
    then
      break
    fi
    sleep 60
done

gsutil rm -r gs://$(gcloud deployment-manager resources list --deployment $DEMO_PROJECT | grep storage.v1.bucket | cut -d' ' -f1)/*
gcloud sql instances delete $DB_NAME --quiet
gcloud deployment-manager deployments delete ${DEMO_PROJECT} --quiet

if [ "${MINUTES}" = "0" ]
then
  echo "The application did not successfully respond, but the database and deployment were deleted."
  return 1
fi
