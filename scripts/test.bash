# Confirm if applied correctly
echo "Did the apply succeed ? (y/n)"
read success_response

if [[ $success_response == "n" ]]; then 
 echo "Terrafrom Apply will now run!"
 terraform plan -out ./.plan
 terraform apply ./.plan
elif [[ $success_response == "y" ]]; then 
 echo "Please continue"
fi 