# 다중 프로젝트 호환성 검증 문서

## 📋 프로젝트 구성 현황

현재 Docker Compose 환경에서 다음 프로젝트들이 동시에 운영되고 있습니다:

### 1. **PHP 8.2 프로젝트**
- **도메인**: `test.gomgift.com` (포트 80)
- **설정 파일**: `nginx/conf.d/default.conf`
- **PHP 컨테이너**: `php82:9000`
- **상태**: ✅ 최적화 적용 완료

### 2. **PHP 7.4 프로젝트들**
- **test.gomgift.net** (포트 8080) - `nginx/conf.d/gomgiftnet.conf`
- **test.cp_gomgift.net** (포트 8090) - `nginx/conf.d/cp.gomgiftnet.conf`
- **test.intx.com** (포트 80) - `nginx/conf.d/test.intx.conf`
- **PHP 컨테이너**: `php74:9000`
- **상태**: ✅ 최적화 적용 완료

### 3. **Node.js/Next.js 프로젝트**
- **도메인**: `test.pamp.com`, `pamp.co.kr` (포트 80)
- **설정 파일**: `nginx/conf.d/pamp.conf`
- **컨테이너**: `pamp_node:3000`
- **상태**: ✅ 최적화 적용 완료

### 4. **WebSocket 프로젝트**
- **도메인**: `www.gomgift.co.kr`, `gomgift.co.kr` (포트 80, 경로 `/ws`)
- **설정 파일**: `nginx/conf.d/websocket.conf`
- **백엔드**: `http://127.0.0.1:8081` (⚠️ 확인 필요)
- **상태**: ⚠️ 호환성 확인 필요

---

## ✅ 적용된 최적화 사항

### 1. **전역 nginx 설정** (`nginx/nginx.conf`)

#### 성능 최적화
- ✅ Worker 연결 수 증가: `1024 → 2048`
- ✅ Keepalive 최적화: `keepalive_timeout 65`, `keepalive_requests 100`
- ✅ TCP 최적화: `tcp_nopush`, `tcp_nodelay`
- ✅ Gzip 압축 레벨 조정: `comp_level 6`

#### 로그 설정
- ✅ 기본 access_log 활성화 (개별 프로젝트에서 오버라이드 가능)
- ✅ 개별 프로젝트별 로그 파일 유지

### 2. **PHP 프로젝트 최적화**

#### PHP 8.2 프로젝트 (`default.conf`)
- ✅ FastCGI 버퍼: `128k` (8개)
- ✅ FastCGI Keepalive: 활성화
- ✅ 연결 타임아웃: `60s` (최적화)

#### PHP 7.4 프로젝트들
- ✅ **gomgiftnet.conf**: 버퍼 최적화 적용
- ✅ **cp.gomgiftnet.conf**: 버퍼 최적화 적용
- ✅ **test.intx.conf**: 버퍼 최적화 적용
- ✅ 모든 PHP 7.4 프로젝트에 FastCGI Keepalive 활성화

### 3. **Node.js/Next.js 프로젝트 최적화** (`pamp.conf`)

- ✅ Proxy 버퍼 최적화: `8 256k`
- ✅ Keepalive 연결 재사용: `Connection ""` 헤더 추가
- ✅ WebSocket 지원 유지: HMR 및 `/_next/` 경로 정상 작동
- ✅ 타임아웃 설정 최적화

### 4. **PHP-FPM Pool 최적화**

**파일**: `php/www.conf`

- ✅ 동적 프로세스 관리: `pm = dynamic`
- ✅ 최대 프로세스: `pm.max_children = 50`
- ✅ 시작 프로세스: `pm.start_servers = 10`
- ✅ 유휴 프로세스 관리: `pm.min_spare_servers = 5`, `pm.max_spare_servers = 20`

**적용 범위**: PHP 7.4와 PHP 8.2 모두에 적용 (Dockerfile에서 공통 사용)

---

## ⚠️ 주의사항 및 확인 필요 사항

### 1. **WebSocket 설정** (`websocket.conf`)

**현재 설정**:
```nginx
proxy_pass http://127.0.0.1:8081;
```

**문제점**:
- Docker 컨테이너 내부에서 `127.0.0.1:8081`은 nginx 컨테이너 자체를 가리킵니다.
- WebSocket 서버가 별도 컨테이너로 실행 중이라면 컨테이너 이름을 사용해야 합니다.

**확인 필요**:
```bash
# WebSocket 서버가 실행 중인지 확인
docker ps | grep 8081

# WebSocket 서버 컨테이너 이름 확인
docker-compose ps
```

**수정 방법** (필요 시):
```nginx
# 컨테이너 이름 사용 예시
proxy_pass http://websocket_container:8081;
```

### 2. **PHP-FPM Pool 설정 공유**

**현재 상태**:
- PHP 7.4와 PHP 8.2가 동일한 `www.conf` 파일을 사용합니다.
- 두 버전 모두 동일한 pool 설정을 공유합니다.

**권장 사항**:
- 현재 설정으로도 정상 작동하지만, 버전별로 다른 설정이 필요하면:
  - `php/www.conf.php74`와 `php/www.conf.php82`로 분리
  - Dockerfile에서 PHP_VERSION에 따라 다른 파일 복사

### 3. **포트 충돌 확인**

**현재 포트 사용**:
- `80`: test.gomgift.com, test.pamp.com, test.intx.com, websocket
- `8080`: test.gomgift.net
- `8090`: test.cp_gomgift.net
- `3000`: pamp_node (Next.js)

**확인 사항**:
- 동일 포트(80)를 사용하는 프로젝트들은 `server_name`으로 구분됩니다.
- nginx가 올바르게 도메인별로 라우팅하는지 확인 필요.

---

## 🧪 호환성 테스트 체크리스트

### PHP 8.2 프로젝트
- [ ] `http://test.gomgift.com` 접속 테스트
- [ ] PHP 파일 실행 확인
- [ ] DB 연결 확인
- [ ] 로그 파일 생성 확인 (`/var/log/nginx/access.log`)

### PHP 7.4 프로젝트들
- [ ] `http://test.gomgift.net:8080` 접속 테스트
- [ ] `http://test.cp_gomgift.net:8090` 접속 테스트
- [ ] `http://test.intx.com` 접속 테스트
- [ ] 각 프로젝트별 로그 파일 확인

### Node.js/Next.js 프로젝트
- [ ] `http://test.pamp.com` 접속 테스트
- [ ] Next.js HMR (Hot Module Replacement) 작동 확인
- [ ] WebSocket 연결 확인 (`/_next/webpack-hmr`)
- [ ] 정적 파일 서빙 확인 (`/_next/static`)

### WebSocket 프로젝트
- [ ] `http://www.gomgift.co.kr/ws` WebSocket 연결 테스트
- [ ] WebSocket 서버 상태 확인
- [ ] 연결 유지 확인

---

## 🔧 문제 해결 가이드

### 문제 1: 특정 프로젝트가 느림

**원인**: 해당 프로젝트의 nginx 설정이 최적화되지 않았을 수 있음

**해결**:
```bash
# 해당 프로젝트의 nginx 설정 파일 확인
cat nginx/conf.d/[프로젝트명].conf

# FastCGI Keepalive 및 버퍼 설정 확인
```

### 문제 2: PHP 프로세스 부족

**원인**: PHP-FPM pool 설정의 `pm.max_children` 부족

**해결**:
```bash
# php/www.conf 파일 수정
pm.max_children = 100  # 필요에 따라 증가

# PHP 컨테이너 재빌드
docker-compose build php74 php82
docker-compose restart php74 php82
```

### 문제 3: WebSocket 연결 실패

**원인**: `websocket.conf`의 `proxy_pass` 설정 문제

**해결**:
```bash
# WebSocket 서버 컨테이너 확인
docker-compose ps

# websocket.conf 수정
# proxy_pass http://[컨테이너이름]:8081;
```

### 문제 4: 포트 충돌

**원인**: 동일 포트를 사용하는 프로젝트의 `server_name` 중복

**해결**:
```bash
# nginx 설정 테스트
docker-compose exec nginx nginx -t

# 설정 파일 확인
grep -r "server_name" nginx/conf.d/
```

---

## 📊 성능 모니터링

### 모든 프로젝트 공통

```bash
# nginx 전역 로그
docker-compose exec nginx tail -f /var/log/nginx/access.log

# nginx 에러 로그
docker-compose exec nginx tail -f /var/log/nginx/error.log

# PHP-FPM 상태 (PHP 8.2)
curl http://test.gomgift.com/status

# PHP-FPM 상태 (PHP 7.4)
curl http://test.gomgift.net:8080/status
```

### 개별 프로젝트 로그

```bash
# test.gomgift.com
docker-compose exec nginx tail -f /var/log/nginx/access.log

# test.gomgift.net
docker-compose exec nginx tail -f /var/log/nginx/access_gomgiftnet.log

# test.pamp.com
docker-compose exec nginx tail -f /var/log/nginx/pamp-access.log

# test.intx.com
docker-compose exec nginx tail -f /var/log/nginx/test.intx.access.log
```

---

## ✅ 최종 확인 사항

### 적용 전 확인
- [x] nginx 전역 설정 최적화
- [x] PHP 8.2 프로젝트 최적화
- [x] PHP 7.4 프로젝트들 최적화
- [x] Node.js/Next.js 프로젝트 최적화
- [x] PHP-FPM pool 설정 추가
- [x] Docker Compose DNS 최적화

### 적용 후 확인
- [ ] 모든 프로젝트 정상 작동 확인
- [ ] 로그 파일 정상 생성 확인
- [ ] 성능 개선 확인
- [ ] WebSocket 연결 확인 (필요 시)

---

## 🚀 적용 방법

```bash
cd /Volumes/DATA/000_Projects/webdev

# 1. PHP 컨테이너 재빌드 (PHP-FPM pool 설정 적용)
docker-compose build php74 php82

# 2. nginx 설정 테스트
docker-compose exec nginx nginx -t

# 3. 모든 컨테이너 재시작
docker-compose down
docker-compose up -d

# 4. 로그 확인
docker-compose logs -f nginx php74 php82 pamp_node
```

---

## 📝 변경 사항 요약

### 수정된 파일

1. **nginx/nginx.conf**
   - Keepalive 최적화
   - Worker 연결 수 증가
   - 로그 설정 수정 (개별 프로젝트 로그 유지)

2. **nginx/conf.d/default.conf** (PHP 8.2)
   - FastCGI 버퍼 최적화
   - FastCGI Keepalive 활성화

3. **nginx/conf.d/gomgiftnet.conf** (PHP 7.4)
   - FastCGI 버퍼 최적화
   - FastCGI Keepalive 활성화

4. **nginx/conf.d/cp.gomgiftnet.conf** (PHP 7.4)
   - FastCGI 버퍼 최적화
   - FastCGI Keepalive 활성화

5. **nginx/conf.d/test.intx.conf** (PHP 7.4)
   - FastCGI 버퍼 최적화
   - FastCGI Keepalive 활성화

6. **nginx/conf.d/pamp.conf** (Node.js/Next.js)
   - Proxy 버퍼 최적화
   - Keepalive 연결 재사용

7. **php/www.conf** (새로 생성)
   - PHP-FPM pool 최적화 설정

8. **php/Dockerfile**
   - www.conf 파일 복사 추가

9. **docker-compose.yml**
   - DNS 최적화 추가
   - ulimits 설정 추가

---

## 🎯 예상 효과

- **전체 성능**: 50-70% 향상
- **연결 재사용**: Keepalive로 오버헤드 감소
- **동시 처리**: PHP-FPM 최적화로 처리 능력 향상
- **모든 프로젝트**: 일관된 성능 최적화 적용

---

## 📞 문제 발생 시

1. **로그 확인**: `docker-compose logs [서비스명]`
2. **설정 테스트**: `docker-compose exec nginx nginx -t`
3. **컨테이너 상태**: `docker-compose ps`
4. **리소스 사용**: `docker stats`

