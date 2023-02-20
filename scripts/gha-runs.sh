#!/bin/bash

# input repo information
OWNER=groupm-global
REPO=mcm-mlab-ui-web-app

# function to delete manually disabled workflow
function delete_runs (){
    for WORKFLOW_ID in $WORKFLOW_ID
    do 
        echo "Deleting runs: $WORKFLOW_ID"
        gh api -X GET /repos/$OWNER/$REPO/actions/workflows/$WORKFLOW_ID/runs | jq '.workflow_runs[] | .id' | xargs -I{} gh api -X DELETE /repos/$OWNER/$REPO/actions/runs/{}
    done
}

# echo repo information
echo $OWNER
echo $REPO

# delete runs
for (( ; ; ))
do 
# set workflow id variable - only disabled_manually workflows
    WORKFLOW_ID=$(gh api -X GET /repos/$OWNER/$REPO/actions/workflows | jq '.workflows[] | select(.state == "disabled_manually") | .id')
# if workflow_id has a value, run delete_runs function
    if [ -n "${WORKFLOW_ID}" ];
    then
    delete_runs
    else
# if workflow_id has no value, echo exit command
    echo "There are no disabled manually workflows"
    exit
    fi
done