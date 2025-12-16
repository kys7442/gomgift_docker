# Next.js 배포 및 운영 가이드

## 개발 환경 설정

### 1. 의존성 설치
```bash
cd /Volumes/DATA/000_Projects/webdev/www/pamp
npm install
```

### 2. 환경 변수 설정

`.env.local` 파일 생성:
```env
# 데이터베이스 설정
DB_HOST=localhost
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=your_db_name

# JWT 시크릿 (인증용)
JWT_SECRET=your_jwt_secret_key

# API 기본 URL
NEXT_PUBLIC_API_URL=https://pamp.co.kr
```

### 3. 개발 서버 실행
```bash
npm run dev
```

개발 서버는 `http://localhost:3000`에서 실행됩니다.

## 프로덕션 빌드

### 1. 빌드
```bash
npm run build
```

### 2. 프로덕션 서버 실행
```bash
npm start
```

## 배포 방법

### 방법 1: Vercel 배포 (권장)

1. **Vercel 계정 생성 및 프로젝트 연결**
   ```bash
   npm i -g vercel
   vercel login
   vercel
   ```

2. **환경 변수 설정**
   - Vercel 대시보드 → 프로젝트 → Settings → Environment Variables
   - `.env.local`의 모든 변수 추가

3. **자동 배포**
   - GitHub에 푸시하면 자동으로 배포됩니다.
   - 또는 `vercel --prod` 명령어로 수동 배포

### 방법 2: 자체 서버 배포

#### PM2 사용 (권장)

1. **PM2 설치**
   ```bash
   npm install -g pm2
   ```

2. **빌드 및 시작**
   ```bash
   npm run build
   pm2 start npm --name "pamp-app" -- start
   ```

3. **PM2 관리 명령어**
   ```bash
   pm2 list          # 프로세스 목록
   pm2 logs          # 로그 확인
   pm2 restart all   # 재시작
   pm2 stop all      # 중지
   pm2 delete all    # 삭제
   ```

#### Nginx 리버스 프록시 설정

`/etc/nginx/sites-available/pamp`:
```nginx
server {
    listen 80;
    server_name pamp.co.kr;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

SSL 인증서 적용 (Let's Encrypt):
```bash
sudo certbot --nginx -d pamp.co.kr
```

### 방법 3: Docker 배포

1. **Dockerfile 생성**
   ```dockerfile
   FROM node:18-alpine
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci --only=production
   COPY . .
   RUN npm run build
   EXPOSE 3000
   CMD ["npm", "start"]
   ```

2. **빌드 및 실행**
   ```bash
   docker build -t pamp-app .
   docker run -p 3000:3000 --env-file .env.local pamp-app
   ```

## 운영 환경 체크리스트

### 배포 전 확인사항

- [ ] 환경 변수 설정 완료
- [ ] 데이터베이스 연결 확인
- [ ] API 엔드포인트 테스트
- [ ] 정적 파일 경로 확인 (`public/` 폴더)
- [ ] 에러 핸들링 확인
- [ ] 로그 설정 확인

### 배포 후 확인사항

- [ ] 홈페이지 접속 확인
- [ ] API 엔드포인트 동작 확인
- [ ] 데이터베이스 쿼리 성능 확인
- [ ] 로그 모니터링
- [ ] 에러 알림 설정

## 모니터링 및 로그

### 로그 확인

**Vercel:**
- 대시보드 → 프로젝트 → Logs

**PM2:**
```bash
pm2 logs pamp-app
```

**Docker:**
```bash
docker logs <container_id>
```

### 성능 모니터링

- Vercel Analytics 사용
- 또는 Google Analytics 추가

## 롤백 방법

### Vercel
```bash
vercel rollback
```

### PM2
```bash
pm2 restart pamp-app
# 또는 이전 버전으로 재배포
```

## 데이터베이스 백업

### 정기 백업 스크립트
```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
mysqldump -u $DB_USER -p$DB_PASSWORD $DB_NAME > backup_$DATE.sql
```

## 보안 체크리스트

- [ ] 환경 변수에 민감한 정보 저장 (`.env.local`은 Git에 커밋하지 않음)
- [ ] JWT 시크릿 키 강력하게 설정
- [ ] HTTPS 사용 (SSL 인증서 적용)
- [ ] SQL Injection 방지 (파라미터화된 쿼리 사용)
- [ ] XSS 방지 (sanitize-html 사용)
- [ ] CORS 설정 확인
- [ ] Rate Limiting 적용 고려

## 트러블슈팅

### 빌드 실패
```bash
# 캐시 삭제 후 재빌드
rm -rf .next
npm run build
```

### 포트 충돌
```bash
# 다른 프로세스가 3000 포트 사용 중인지 확인
lsof -i :3000
```

### 데이터베이스 연결 오류
- 환경 변수 확인
- 데이터베이스 서버 상태 확인
- 방화벽 설정 확인

## 업데이트 프로세스

1. **코드 변경**
   ```bash
   git pull origin main
   ```

2. **의존성 업데이트 (필요시)**
   ```bash
   npm install
   ```

3. **빌드**
   ```bash
   npm run build
   ```

4. **재시작**
   ```bash
   pm2 restart pamp-app
   # 또는 Vercel은 자동 배포
   ```

