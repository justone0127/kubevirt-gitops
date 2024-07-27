#!/bin/bash

# 생성할 프로젝트의 개수와 접두사(prefix)를 지정합니다.
project_count=3
project_prefix="test"

# 프로젝트를 생성합니다.
for ((i=1; i<=project_count; i++))
do
    project_name="${project_prefix}${i}-vm"
    echo "Creating project: $project_name"
    oc new-project $project_name
done
