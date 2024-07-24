## Mirror Registry 구성

### 1. Mirror-Registry 설치 파일 다운로드

```bash
mkdir -p /opt/openshift/download/mirror-registry/ 
wget -P /opt/openshift/download/mirror-registry https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/mirror-registry/latest/mirror-registry.tar.gz
```



### 2. 파일 확인 및 압축 해제

```bash
# ls -rlt
total 703164
-rw-r--r--. 1 root root 720037222 May 11 19:17 mirror-registry.tar.gz
```

- 압축 해제

  ```bash
  tar -xzf mirror-registry.tar.gz -C /opt/openshift/download/mirror-registry/ 
  ```

### 3. 호스트 파일 수정

- 호스트 파일 수정

  ```bash
  # cat /etc/hosts
  127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
  ::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
  192.76.168.81   bastion.ocp4.poc.com
  192.76.168.81   init-quay.ocp4.poc.com
  ```

  > \>> mirror-registry가 배포될 호스트 파일과 IP를 추가하여 작성합니다. 베스천에 배포할 경우 베스천 hostname과 IP를 입력합니다.

### 4. 설치 파라미터 설명

- **initUser** : 초기 사용자 계정
- **initPassword** : 초기 사용자 패스워드
- **quayHostname** :  미러 레지스트리 호스트명
- **quayRoot** : 미러 레지스트리 설치 디렉토리
- **pgStorage** : Postgres 영구 저장소 데이터가 저장되는 디렉토리 / pg-storage Podman 볼륨이 기본값
- **quayStorage** : Quay 영구 저장소 데이터가 저장되는 디렉토리 / quay-storage Podman 볼륨이 기본값

### 5. 설치 명령어

```bash
./mirror-registry install --initUser admin --initPassword r3dh4t1! --quayHostname init-quay.ocp4.poc.com:5050 --quayRoot /opt/openshift/init-quay --pgStorage /opt/openshift/init-quay/pg-storage --quayStorage /opt/openshift/init-quay/quay-storage -v
```

- 설치 실패 시 제거 명령어

  ```bash
  ./mirror-registry uninstall -v \
    --quayRoot /opt/openshift/init-quay
  ```

### 6. 미러 레지스트리 인증서 복사

```bash
cp -rf /opt/openshift/init-quay/quay-rootCA/rootCA.pem /etc/pki/ca-trust/source/anchors/
cp -rf /opt/openshift/init-quay/quay-config/ssl.cert /etc/pki/ca-trust/source/anchors/
update-ca-trust
```

### 7. init-quay 레지스트리에 대해 base64로 인코딩된 사용자 이름과 비밀버호 생성

```bash
echo -n "admin:r3dh4t1!" | base64 -w0
YWRtaW46cjNkaDR0MSE=
```

### 8. pull-secret에 해당 정보를 추가

```bash
{
 "auths": {
    "init-quay.ocp4.poc.com:5050": {
      "auth": "YWRtaW46cjNkaDR0MSE=",
      "email": "hyou@redhat.com"
    }
  },
```

### 9. 위에서 생성한 pull-secret.json 파일을 **~/.docker/config.json으로 복사**

```bash
mkdir -p ~/.docker
cp pull-secret.json ~/.docker/config.json
```
