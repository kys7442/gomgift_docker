# Docker 설정 가이드

## 로컬 개발 환경 설정

### 1. /etc/hosts 파일 수정
관리자 권한으로 `/etc/hosts` 파일을 수정하세요:

```bash
sudo nano /etc/hosts
```

다음 줄을 추가:
```
127.0.0.1 test.intx-nextjs.com
```

### 2. Docker 컨테이너 시작

#### 개발 모드 (기본)
```bash
cd /Volumes/DATA/000_Projects/webdev
docker-compose up -d intx_node nginx
```

#### 프로덕션 모드
```bash
cd /Volumes/DATA/000_Projects/webdev
NODE_ENV=production docker-compose up -d intx_node nginx
```

또는 `.env` 파일에 설정:
```bash
echo "NODE_ENV=production" >> .env
docker-compose up -d intx_node nginx
```

### 3. 접속 확인
브라우저에서 `http://test.intx-nextjs.com`으로 접속하세요.

## Docker Compose 구성

### intx_node 서비스
- **포트**: 3001:3000 (호스트:컨테이너)
  - 호스트의 3001 포트는 `pamp_node`가 3000을 사용하므로 충돌 방지
  - 컨테이너 내부는 항상 3000 포트 사용
- **볼륨**: `./www/intx-nextjs` → `/usr/src/app`
- **네트워크**: `webnet`
- **명령어**: 
  - 개발 모드: `npm run dev --webpack -- -H 0.0.0.0`
  - 프로덕션 모드: `npm run build --webpack && npm run start -- -H 0.0.0.0`

### nginx 설정
- **설정 파일**: `nginx/conf.d/intx-nextjs.conf`
- **도메인**: `test.intx-nextjs.com`
- **프록시**: `http://intx_node:3000` (컨테이너 내부 네트워크)

## 포트 구성 설명

### 호스트 포트
- `pamp_node`: 3000 (test.pamp.com)
- `intx_node`: 3001 (test.intx-nextjs.com)

### 컨테이너 내부 포트
- 두 컨테이너 모두 내부적으로 3000 포트 사용
- nginx는 컨테이너 이름으로 프록시: `pamp_node:3000`, `intx_node:3000`

## 프로덕션 배포

### 1. 빌드 및 시작
```bash
cd /Volumes/DATA/000_Projects/webdev
NODE_ENV=production docker-compose up -d --build intx_node
```

### 2. 로그 확인
```bash
docker-compose logs -f intx_node
```

### 3. 재시작
```bash
docker-compose restart intx_node nginx
```

## 문제 해결

### 컨테이너가 시작되지 않는 경우
```bash
# 로그 확인
docker-compose logs intx_node

# 컨테이너 재시작
docker-compose restart intx_node nginx
```

### 포트 충돌이 발생하는 경우
호스트의 3001 포트가 사용 중이면 다른 포트로 변경:
```yaml
intx_node:
  ports:
    - "3002:3000"  # 다른 포트로 변경
```

그리고 nginx 설정은 변경할 필요 없음 (컨테이너 내부 네트워크 사용)

### npm install 오류가 발생하는 경우
컨테이너 내부에서 직접 실행:
```bash
docker-compose exec intx_node sh
npm install --legacy-peer-deps
```

### 프로덕션 빌드 오류
```bash
# 컨테이너 내부에서 빌드
docker-compose exec intx_node sh
npm run build --webpack
npm run start -- -H 0.0.0.0
```

## 로컬에서 직접 실행 (도커 없이)

### 개발 모드
```bash
cd /Volumes/DATA/000_Projects/webdev/www/intx-nextjs
npm run dev --webpack -H 0.0.0.0 -p 3001
```

### 프로덕션 모드
```bash
cd /Volumes/DATA/000_Projects/webdev/www/intx-nextjs
npm run build --webpack
npm run start -- -H 0.0.0.0 -p 3001
```

**주의**: 로컬에서 직접 실행할 때는 nginx가 `localhost:3001`로 프록시하도록 설정을 변경해야 합니다.

docker logs -f php