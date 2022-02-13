#!/bin/bash

TEMP=$TMPDIR'ecs-images.json'

regions=(
  'us-west-2'
  'us-east-2'
  'ap-southeast-1'
)

echo "${regions[@]}"

for region in "${regions[@]}"; do
  echo Scaning region "$region"
  clusters=$(aws ecs list-clusters --region "$region" --query 'clusterArns' --output text)

  for cluster in $clusters; do
    echo Scaning clusters "$cluster"...
    IFS=" " read -r -a tasks <<< "$(aws ecs list-tasks --region "$region" --cluster="$cluster" --desired-status RUNNING --query taskArns | jq -r '.[]' | tr -s '\n' ' ')"
    echo "${tasks[@]}"

    for task in "${tasks[@]}"; do 
      echo Scaning task "$task"...
      aws ecs describe-tasks \
        --region "$region" \
        --cluster "$cluster" \
        --tasks "$task" \
        --query 'tasks[].{Cluster:clusterArn,Service:group,Image:containers[].image,TaskDef:taskDefinitionArn,TaskArn:taskArn,CPU:cpu,Memory:memory,CapacityProvider:capacityProviderName}' \
        --output json >> "$TEMP"
    done
  done  
done
echo All done!

jq -n '[inputs|.[]]' "$TEMP"
rm "$TEMP"
