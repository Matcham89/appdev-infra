#!/bin/bash

function delete_folder()
{
    local parent_folder=$1

    folders=$( gcloud resource-manager folders list --folder="$parent_folder" --format='value(name)' )

    for folder in $folders
    do 
        delete_project $folder
        delete_folder $folder
        echo "Deleting folder: $folder"
        gcloud resource-manager folders delete $folder --quiet
    done
}

function delete_project()
{
    local parent_folder=$1

    projects=$( gcloud projects list --filter="parent.id=$parent_folder" --format='value(projectId)' )

    for project in $projects
    do 
        echo "Deleting project: $project"
        delete_project_lien $project
        gcloud projects delete $project --quiet
    done
}

function delete_project_lien()
{
    local project_id=$1

    project_liens=$( gcloud alpha resource-manager liens list --format="value(name)" --project=${project_id} )

    for lien in $project_liens
    do 
        echo "Deleting project lien: $lien"
        gcloud alpha resource-manager liens delete ${lien} --project=${project_id}
    done
}

# Delete all folders and projects under the PENDING DELETION folder (Folder ID 543916537772)
delete_folder "1029706125675"