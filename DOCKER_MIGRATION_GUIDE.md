# 🐳 Docker Migration & Operation Guide

이 문서는 기존 CentOS 9 + Native Nginx/PHP/Node 환경에서 Docker 환경으로 전환하기 위한 전략과 답변을 정리한 가이드입니다.

## 1. 핵심 질문에 대한 답변

### Q1. 기존 실 서버 환경에 Docker 환경을 추가 구성해도 문제가 없는가?
**A: 네, 가능합니다. 단, "포트 충돌"만 주의하면 됩니다.**
- **문제점**: 기존 서버의 Nginx가 이미 `80`, `443` 포트를 사용 중입니다. `docker-compose.yml`에 정의된 Nginx도 `80` 포트를 쓰려고 하면 **에러가 발생하여 켜지지 않습니다.**
- **해결책**:
    1. **테스트 단계**: Docker Nginx의 포트를 `8000:80` 처럼 다른 포트로 매핑하여 띄우고 테스트합니다.
    2. **전환 단계**: 기존 Nginx를 중지(`systemctl stop nginx`)하고 Docker Nginx를 `80:80`으로 띄웁니다.
    3. **공존 단계 (추천)**: 기존 Nginx를 "메인 프록시"로 두고, 특정 도메인만 Docker Nginx(예: 8000포트)로 토스하는 방식도 가능합니다. 하지만 관리가 복잡해지므로 **최종적으로는 Docker로 완전 전환**하는 것을 권장합니다.

### Q2. Git으로 Docker 설정을 관리해도 되는가?
**A: 강력히 권장합니다 (Infrastructure as Code).**
- 현재 보고 계신 `docker-compose.yml`, `nginx/conf.d/*.conf`, `php/Dockerfile` 등이 모두 서버의 "설계도"입니다.
- 이를 Git으로 관리하면 서버 환경을 언제든 복구하거나, 다른 서버에 똑같이 복제할 수 있습니다.

### Q3. Docker 안의 프로젝트들도 Git으로 관리하는데 지장이 없는가?
**A: 지장 없습니다. 다만 "어디서 Git 명령을 치느냐"가 중요합니다.**
- **권장 방식 (Host 중심)**:
    - 소스 코드는 호스트(실 서버)의 폴더(예: `./www/project_A`)에 둡니다.
    - **Git 명령(`pull`, `checkout`)은 호스트에서 실행합니다.**
    - Docker 컨테이너는 이 폴더를 `volumes`로 마운트하여 바라보기만 합니다.
    - 이 방식이 권한 문제나 인증 처리가 가장 쉽습니다.
- **컨테이너 내부 방식**:
    - 컨테이너 안에서 `git pull`을 하려면 SSH 키 전달 등이 필요하여 번거롭습니다. 개발 환경이 아닌 이상 권장하지 않습니다.

### Q4. 로컬 개발 vs 실 서버 배포 시 주의점은?
**A: 데이터베이스와 파일 권한이 가장 중요합니다.**
- **DB 데이터**: 기존 서버에 로컬 MariaDB가 깔려 있다면, Docker MariaDB로 데이터를 **이관(Dump & Restore)** 해야 합니다. 혹은 Docker 앱들이 호스트의 DB를 바라보게 설정해야 합니다.
- **파일 업로드**: 사용자가 업로드한 이미지 등이 저장되는 경로(예: `uploads/`)는 반드시 호스트의 영구적인 폴더와 마운트되어야 컨테이너가 재시작돼도 데이터가 사라지지 않습니다.

---

## 2. 🚀 단계별 전환 시나리오 (Migration Strategy)

가장 안전한 **"병행 운영 후 전환(Blue/Green 유사)"** 방식을 제안합니다.

### 1단계: 포트 회피 기동 (Staging)
기존 서비스는 건드리지 않고 Docker 서비스를 띄웁니다.

1. `docker-compose.yml` 수정:
   ```yaml
   services:
     nginx:
       ports:
         - "8081:80"   # 80 포트 대신 8081 사용
         - "8443:443"
   ```
2. 실행: `docker-compose up -d`
3. 테스트: `http://서버IP:8081` 로 접속하여 Docker 환경의 서비스들이 잘 뜨는지 확인합니다.

### 2단계: 데이터 이관 (Data Migration)
기존 서버의 DB와 정적 파일들을 Docker 환경이 바라보는 폴더로 가져옵니다.

- **DB**: `mysqldump`로 백업 후 Docker MariaDB에 import.
- **소스**: `www` 폴더에 최신 소스 `git pull`.

### 3단계: 서비스 전환 (Cutover)
**주의: 짧은 다운타임이 발생합니다.**

1. 기존 Nginx/PHP/Node 중지:
   ```bash
   sudo systemctl stop nginx php-fpm
   # Node 프로세스도 종료 (pm2 stop all 등)
   ```
2. `docker-compose.yml` 포트 원복:
   ```yaml
   services:
     nginx:
       ports:
         - "80:80"
         - "443:443"
   ```
3. Docker 재시작:
   ```bash
   docker-compose up -d --force-recreate nginx
   ```
4. 접속 확인.

### 4단계: 롤백 (유사시)
만약 문제가 생기면?
1. `docker-compose down`
2. `sudo systemctl start nginx php-fpm`
3. 기존 환경으로 즉시 복구됩니다.

---

## 3. ⚠️ 실무 운영 팁 (Best Practices)

### 1. `restart: always` 정책
- 서버가 재부팅되었을 때 Docker 컨테이너도 자동으로 켜져야 합니다.
- `docker-compose.yml`에 `restart: always` 또는 `unless-stopped`가 모든 서비스에 있는지 확인하세요. (현재 설정에 잘 되어 있습니다!)

### 2. 로그 관리
- Docker 로그는 계속 쌓이면 디스크를 꽉 채울 수 있습니다.
- `docker-compose.yml`에 로그 로테이션 설정을 추가하는 것이 좋습니다.
  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```

### 3. 권한 문제 (Permission)
- 호스트(Linux)와 컨테이너(Linux)의 UID가 다르면 파일 수정이 안 될 수 있습니다.
- PHP/Nginx는 보통 `www-data` (uid 33) 또는 `nginx` (uid 101) 등을 씁니다.
- 호스트의 `www` 폴더 권한을 맞춰주거나, Dockerfile에서 유저 ID를 호스트와 일치시키는 작업이 필요할 수 있습니다.

### 4. 데이터베이스 (가장 중요)
- **기존 DB**를 계속 쓸 것인가? **Docker DB**로 옮길 것인가?
- **기존 DB 유지 시**: Docker 앱들이 `host.docker.internal` (리눅스에선 설정 필요) 또는 `172.17.0.1`을 통해 호스트 DB에 접속해야 합니다.
- **Docker DB 전환 시**: 데이터 백업/복구가 필수입니다. 볼륨(`- ./mysql/data:/var/lib/mysql`)이 잘 잡혀있는지 두 번 확인하세요.
