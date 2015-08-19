#!/bin/bash

C=$1
while [ "$(docker inspect --format='{{ .State.Running }}' $C 2> /dev/null)" == "true" ]
do
  echo "Waiting for container $C to stop"
  sleep 5;
done
