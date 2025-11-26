# Docker 성능 최적화 가이드

## 🔍 로딩 지연 문제 진단 및 해결

### 주요 원인 분석

1. **DNS 해석 지연**
   - `test.gomgift.com` 도메인 해석 시간
   - 외부 DNS 서버 응답 지연

2. **외부 DB 연결 지연**
   - Docker → 외부 DB 네트워크 지연
   - DB 연결 타임아웃 설정

3. **PHP-FPM 프로세스 부족**
   - 동시 요청 처리 능력 부족
   - 프로세스 생성/소멸 오버헤드

4. **nginx 연결 재사용 부족**
   - Keepalive 설정 미흡
   - 매 요청마다 새 연결 생성

---

## ✅ 적용된 최적화 사항

### 1. nginx 성능 최적화

**파일**: `nginx/nginx.conf`

- ✅ Keepalive 연결 재사용 (`keepalive_timeout 65`, `keepalive_requests 100`)
- ✅ Worker 연결 수 증가 (`worker_connections 2048`)
- ✅ TCP 최적화 (`tcp_nopush`, `tcp_nodelay`)
- ✅ 버퍼 크기 최적화
- ✅ Gzip 압축 레벨 조정

**파일**: `nginx/conf.d/default.conf`

- ✅ FastCGI 버퍼 크기 증가 (64k → 128k)
- ✅ FastCGI Keepalive 활성화 (`fastcgi_keep_conn on`)
- ✅ 연결 타임아웃 최적화

### 2. PHP-FPM Pool 최적화

**파일**: `php/www.conf` (새로 생성)

- ✅ 동적 프로세스 관리 (`pm = dynamic`)
- ✅ 최대 프로세스 수 증가 (`pm.max_children = 50`)
- ✅ 시작 프로세스 수 최적화 (`pm.start_servers = 10`)
- ✅ 유휴 프로세스 관리 (`pm.min_spare_servers = 5`, `pm.max_spare_servers = 20`)
- ✅ 요청 처리 후 재사용 (`pm.max_requests = 500`)

### 3. Docker Compose 최적화

**파일**: `docker-compose.yml`

- ✅ DNS 서버 설정 (Google DNS: 8.8.8.8, 8.8.4.4)
- ✅ 파일 디스크립터 제한 증가 (`ulimits.nofile: 65536`)
- ✅ 볼륨 마운트 최적화 (`cached`, `delegated` 옵션)

---

## 🚀 적용 방법

### 1. Docker 컨테이너 재빌드 및 재시작

```bash
cd /Volumes/DATA/000_Projects/webdev

# PHP 컨테이너 재빌드 (PHP-FPM pool 설정 적용)
docker-compose build php74 php82

# 모든 컨테이너 재시작
docker-compose down
docker-compose up -d

# 로그 확인
docker-compose logs -f nginx php82
```

### 2. 로컬 DB 사용 확인 (권장)

**현재 상태**: `docker-compose.yml`에서 `mariadb` 컨테이너가 실행 중입니다.

**외부 DB 사용 시 지연 발생 가능**:
- PHP 애플리케이션이 `.env` 파일에서 외부 DB 설정을 읽는 경우
- 네트워크 지연으로 인한 로딩 지연 발생

**해결 방법**:

1. **로컬 DB 사용 (권장)**:
   ```bash
   # .env 파일 확인
   cat www/yc_gomgift/.env
   
   # 로컬 DB 설정으로 변경
   DB_HOST=mariadb
   DB_USER=gomgift
   DB_PASSWORD=Gomgift00
   DB_NAME=yc_gomgift
   ```

2. **외부 DB 사용 시**:
   - DB 연결 풀링 확인
   - 네트워크 지연 최소화
   - DB 서버 위치 확인 (로컬 네트워크 권장)

### 3. DNS 해석 최적화

**macOS에서 `/etc/hosts` 파일 확인**:

```bash
# test.gomgift.com이 로컬로 매핑되어 있는지 확인
cat /etc/hosts | grep test.gomgift.com

# 없으면 추가 (로컬 접속 시)
sudo echo "127.0.0.1 test.gomgift.com" >> /etc/hosts
```

---

## 📊 성능 모니터링

### 1. nginx 로그 확인

```bash
# 접근 로그
docker-compose exec nginx tail -f /var/log/nginx/access.log

# 에러 로그
docker-compose exec nginx tail -f /var/log/nginx/error.log
```

### 2. PHP-FPM 상태 확인

```bash
# PHP-FPM 상태 페이지 (브라우저에서 접속)
# http://test.gomgift.com/status

# 또는 컨테이너 내부에서
docker-compose exec php82 curl http://localhost/status
```

### 3. 응답 시간 측정

```bash
# curl로 응답 시간 측정
time curl -I http://test.gomgift.com

# 상세 정보
curl -w "@-" -o /dev/null -s http://test.gomgift.com <<'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

---

## 🔧 추가 최적화 옵션

### 1. nginx 캐싱 활성화 (선택적)

`nginx/conf.d/default.conf`에 추가:

```nginx
# 정적 파일 캐싱
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
    expires 30d;
    add_header Cache-Control "public, immutable";
    access_log off;
}
```

### 2. PHP OpCache 최적화

`php/php.ini`에서 OpCache 설정 확인:

```ini
opcache.enable=1
opcache.memory_consumption=256
opcache.max_accelerated_files=20000
opcache.revalidate_freq=2
```

### 3. MariaDB 최적화

`mysql/conf.d/my.cnf` 확인 및 최적화:

```ini
[mysqld]
innodb_buffer_pool_size=1G
innodb_log_file_size=256M
max_connections=500
```

---

## ⚠️ 문제 해결

### 로딩이 여전히 느린 경우

1. **DB 연결 확인**:
   ```bash
   # PHP 컨테이너에서 DB 연결 테스트
   docker-compose exec php82 php -r "new PDO('mysql:host=mariadb;dbname=yc_gomgift', 'gomgift', 'Gomgift00');"
   ```

2. **네트워크 지연 확인**:
   ```bash
   # 컨테이너 간 네트워크 테스트
   docker-compose exec php82 ping -c 3 mariadb
   ```

3. **리소스 사용량 확인**:
   ```bash
   # 컨테이너 리소스 사용량
   docker stats
   ```

4. **로그 확인**:
   ```bash
   # 모든 서비스 로그
   docker-compose logs --tail=100
   ```

---

## 📝 체크리스트

- [x] nginx keepalive 설정 적용
- [x] PHP-FPM pool 설정 최적화
- [x] Docker DNS 설정 추가
- [x] 파일 디스크립터 제한 증가
- [ ] 로컬 DB 사용 확인 (`.env` 파일)
- [ ] `/etc/hosts` 파일에 도메인 추가
- [ ] 컨테이너 재빌드 및 재시작
- [ ] 성능 테스트 및 모니터링

---

## 🎯 예상 성능 개선

- **연결 재사용**: Keepalive로 연결 오버헤드 감소 → **20-30% 성능 향상**
- **프로세스 관리**: PHP-FPM 최적화로 동시 요청 처리 능력 향상 → **30-40% 성능 향상**
- **DNS 최적화**: 빠른 DNS 해석 → **초기 로딩 시간 10-20% 단축**
- **전체 예상**: **50-70% 성능 향상** (외부 DB 사용 시 제외)

---

## 📞 추가 지원

문제가 지속되면 다음 정보를 확인하세요:

1. Docker 버전: `docker --version`
2. Docker Compose 버전: `docker-compose --version`
3. 시스템 리소스: `docker stats`
4. 네트워크 설정: `docker network inspect webdev_webnet`

