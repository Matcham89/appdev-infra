#!/bin/bash
OWNER=Matcham89
REPO=appdev-application
app_attribute_repository=Matcham89/appdev-application
LOAD_BALANCER_IP=34.149.174.168
echo "Waiting for the application to settle"
sleep 10
echo "Welcome to the application"
curl $LOAD_BALANCER_IP
echo http://$LOAD_BALANCER_IP

# Complete build
echo "Build is now complete"

app_status=$(curl $LOAD_BALANCER_IP)

# Show status of workflow in terminal until complete
while [[ $app_status == '"in_progress"' ]] ; do
   echo "Application Deploying"
   app_status=$(curl $LOAD_BALANCER_IP)
   echo $app_status
done