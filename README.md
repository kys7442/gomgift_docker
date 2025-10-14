# Docker 웹 개발 환경

이 프로젝트는 PHP, Nginx, MariaDB를 사용한 웹 개발 환경입니다.

## 구성 요소

- **Nginx**: 웹 서버 (포트 80)
- **PHP 8.2**: PHP-FPM with 필수 모듈 (gd, mysql, curl, mbstring 등)
- **MariaDB 10.11**: 데이터베이스 서버 (포트 3306)

## 설치된 PHP 모듈

- gd (이미지 처리)
- pdo_mysql, mysqli (MySQL/MariaDB 연결)
- curl (HTTP 요청)
- mbstring (멀티바이트 문자열)
- xml (XML 처리)
- zip (압축 파일)
- opcache (성능 최적화)
- bcmath (정밀 계산)
- soap (SOAP 웹서비스)
- sockets (소켓 통신)
- exif (이미지 메타데이터)
- intl (국제화)
- calendar (달력 함수)
- wddx (WDDX 직렬화)

## 사용 방법

### 1. 도커 컨테이너 실행

```bash
docker-compose up -d
```

### 2. 도메인 설정

로컬에서 `test.gomgift.com` 도메인을 사용하려면 `/etc/hosts` 파일에 다음을 추가하세요:

```
127.0.0.1 test.gomgift.com
```

### 3. 접속 확인

- 웹사이트: http://test.gomgift.com
- PHP 정보: http://test.gomgift.com/index.php
- DB 연결 테스트: http://test.gomgift.com/test_db_connection.php

## 데이터베이스 설정

### 로컬 MariaDB
- 호스트: mariadb (컨테이너 내부) 또는 localhost:3306 (외부 접근)
- 데이터베이스: yc_gomgift
- 사용자: gomgift
- 비밀번호: Gomgift00

### 외부 DB 연결

외부 DB를 사용하려면 다음 파일들을 수정하세요:

1. **`www/yc_gomgift/config/external_db.php`**: 외부 DB 서버 정보 설정
   ```php
   $external_db_settings = [
       'host' => 'your-external-db-host.com',
       'port' => '3306',
       'database' => 'yc_gomgift',
       'username' => 'your_external_user',
       'password' => 'your_external_password',
       // SSL 설정 등 추가 옵션
   ];
   ```

2. **`www/yc_gomgift/config/database.php`**: `$use_external_db = true`로 변경

## 프로젝트 구조

```
www/
└── yc_gomgift/
    ├── index.php              # 메인 페이지 (PHP 정보)
    ├── test_db_connection.php # DB 연결 테스트
    └── config/
        ├── database.php       # 로컬 DB 설정 파일
        └── external_db.php    # 외부 DB 설정 파일
```

## 유용한 명령어

```bash
# 컨테이너 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs nginx
docker-compose logs php
docker-compose logs mariadb

# 컨테이너 재시작
docker-compose restart

# 컨테이너 중지
docker-compose down
```

## 문제 해결

1. **도메인 접속 불가**: `/etc/hosts` 파일에 도메인 추가 확인
2. **DB 연결 실패**: 컨테이너가 모두 실행되었는지 확인
3. **PHP 모듈 누락**: PHP 컨테이너 재빌드 (`docker-compose build php`)
