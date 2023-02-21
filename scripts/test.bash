#!/bin/bash
OWNER=Matcham89
REPO=appdev-application
app_attribute_repository=Matcham89/appdev-application


# Set workflow ID
#WORKFLOW_ID=$(gh api -X GET /repos/$OWNER/$REPO/actions/workflows | jq '.workflows[] | select(.name == "cd-workflow") | .id')

WORKFLOW_STATUS=$(gh run list -R $app_attribute_repository --json status,databaseId,name,number | jq '.[0] | .status')
echo $WORKFLOW_STATUS

while [[ $WORKFLOW_STATUS == '"in_progress"' ]] || [[ $WORKFLOW_STATUS == '"queued"' ]] ; do
   gh run list -R $app_attribute_repository
   WORKFLOW_STATUS=$(gh run list -R $app_attribute_repository --json status,databaseId,name,number | jq '.[0] | .status')
done

if [[ $WORKFLOW_STATUS == '"completed"' ]]; then
  echo "Workflow has completed"
  exit
fi