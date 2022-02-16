#!/bin/bash

TYPE=$1

regions=(
  'us-west-2'
  # 'us-east-2'
  # 'ap-southeast-1'
)

ecs-task() {
  TEMP=$TMPDIR'ecs-tasks.json'

  for region in "${regions[@]}"; do
    echo Scaning region "$region"
    clusters=$(aws ecs list-clusters --region "$region" --query 'clusterArns' --output text)

    for cluster in $clusters; do
      echo Scaning clusters "$cluster"...
      IFS=" " read -r -a tasks <<< "$(aws ecs list-tasks --region "$region" --cluster="$cluster" --desired-status RUNNING --query taskArns | jq -r '.[]' | tr -s '\n' ' ')"

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

  jq -n '[inputs|.[]]' "$TEMP" | jq -r '.[]' | jq -s .
  rm "$TEMP"
}

ecs-services() {
  TEMP=$TMPDIR'ecs-services.json'

  for region in "${regions[@]}"; do
    echo Scaning region "$region"
    clusters=$(aws ecs list-clusters --region "$region" --query 'clusterArns' --output text)

    for cluster in $clusters; do
      echo Scaning clusters "$cluster"...
      IFS=" " read -r -a services <<< "$(aws ecs list-services --region "$region" --cluster="$cluster" --query serviceArns | jq -r '.[]' | sed 's|.*/||' | tr -s '\n' ' ')"
      echo "${services[@]}"

      for service in "${services[@]}"; do 
        echo Scaning service "$service"...
        aws ecs describe-services \
          --region "$region" \
          --cluster "$cluster" \
          --services "$service" \
          --query 'services[].{Cluster:clusterArn,Service:serviceName,Desired:desiredCount,Pending:pendingCount,Running:runningCount,TaskDef:deployments[*].taskDefinition,RolloutState:deployments[*].rolloutState}' \
          --output json >> "$TEMP"
      done
    done  
  done
  echo All done!

  jq -n '[inputs|.[]]' "$TEMP" | jq -r '.[]' | jq -s .
  rm "$TEMP"
}

if [ "$TYPE" = "task" ]; then
  ecs-task
elif [ "$TYPE" = "svc" ]; then
  ecs-services
else 
  echo "Invalid argument, usage: 'ecslist task' or 'ecslist svc'"
  return
fi
