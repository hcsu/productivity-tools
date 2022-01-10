#!/bin/bash

TEMP=$TMPDIR'ecs-images.json'

regions=(
  'us-west-2'
  'us-east-2'
  'ap-southeast-1'
)

for region in "${regions[@]}"; do
  echo Scaning region "$region"
  clusters=$(aws ecs list-clusters --region "$region" --query 'clusterArns' --output text)

  for cluster in $clusters; do
    echo Scaning clusters...
    tasks=$(aws ecs list-tasks --region "$region" --cluster="$cluster" --desired-status RUNNING --query taskArns --output text)
    
    for task in $tasks; do 
      echo Scaning tasks...
      aws ecs describe-tasks \
        --region "$region" \
        --cluster "$cluster" \
        --tasks "$task" \
        --query 'tasks[].{Cluster:clusterArn,Service:group,Image:containers[].image}' \
        --output json >> "$TEMP"
    done
  done  
done
echo All done!

jq '[inputs|.[]]' "$TEMP"
rm "$TEMP"
