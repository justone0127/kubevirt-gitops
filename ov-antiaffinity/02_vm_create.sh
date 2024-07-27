#!/bin/bash

# YAML 파일 경로
yaml_file="./yaml/rhel8.9-custom.yaml"

# 네임스페이스 이름 변수
namespace_prefix="test"
namespace_suffix_common="vm"

# 반복문
for ((suffix=1; suffix<=3; suffix++)); do
    namespace="${namespace_prefix}${suffix}-${namespace_suffix_common}"
    echo "Applying YAML for namespace: $namespace"
    oc process -n "$namespace" -f "$yaml_file" | oc apply -f - -n "$namespace"
    
    # 적용이 완료될 때까지 대기
    while oc get pods -n "$namespace" | grep -q 'ContainerCreating'; do
        echo "Waiting for resources to be created in namespace: $namespace"
        sleep 5
    done
done
