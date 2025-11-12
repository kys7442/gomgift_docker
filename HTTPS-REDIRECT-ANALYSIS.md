# HTTPS 자동 리다이렉트 원인 분석 리포트

## ✅ 확인 완료된 항목

### 1. Nginx 설정 파일들
- ✅ `nginx/conf.d/cp.gomgiftnet.conf` (8090 포트)
  - HTTPS 리다이렉트 없음
  - `fastcgi_param HTTPS off;` 설정됨
  - `fastcgi_param HTTP_X_FORWARDED_PROTO http;` 설정됨
  - HSTS 헤더 제거 설정됨
- ✅ `nginx/conf.d/gomgiftnet.conf` (8080 포트)
  - HTTPS 리다이렉트 없음
- ✅ `nginx/conf.d/default.conf` (80 포트)
  - HTTPS 리다이렉트 없음
- ✅ `nginx/nginx.conf`
  - 전역 HTTPS 리다이렉트 없음

### 2. CodeIgniter 설정 (application_cp)
- ✅ `application_cp/config/config.php`
  - 8090 포트 감지 시 HTTP 강제 설정:
    ```php
    $_SERVER['HTTPS'] = 'off';
    unset($_SERVER['HTTP_X_FORWARDED_PROTO']);
    $config['base_url'] = 'http://' . $host;
    ```
  - `cookie_secure = FALSE` 설정됨

### 3. .htaccess 파일
- ✅ `.htaccess`: HTTPS 리다이렉트 없음 (단순 RewriteRule만 존재)
- ✅ `application_cp/.htaccess`: 접근 차단만 설정 (리다이렉트 없음)

### 4. CodeIgniter Core 함수
- ✅ `is_https()` 함수 확인 (`system/core/Common.php:352`)
  - `$_SERVER['HTTPS']` 체크
  - `$_SERVER['HTTP_X_FORWARDED_PROTO']` 체크
  - `$_SERVER['HTTP_FRONT_END_HTTPS']` 체크
- ✅ `redirect()` 함수 확인 (`system/helpers/url_helper.php:532`)
  - `site_url()` 사용 → `base_url` 사용
  - 상대 경로는 `site_url()`로 변환됨

### 5. 컨트롤러
- ✅ `application_cp/controllers/Auth.php`
  - `redirect('dashboard')`, `redirect('auth/login')` 사용 (상대 경로)
  - `base_url`을 통해 URL 생성됨

## 🔍 잠재적 원인

### 1. 브라우저 HSTS 캐시 (가장 가능성 높음)
**증상**: 크롬이 이전에 HTTPS로 접속한 기록이 있으면 자동으로 HTTPS로 리다이렉트

**해결 방법**:
1. 크롬 주소창에 `chrome://net-internals/#hsts` 입력
2. "Delete domain security policies"에서 `192.168.0.24` 입력 후 삭제
3. 크롬 완전 종료 후 재시작

### 2. CodeIgniter Config 클래스 생성자
**위치**: `system/core/Config.php:88-111`

**문제 가능성**: 
- `base_url`이 비어있을 때 자동 설정 로직이 `is_https()` 사용
- 하지만 `application_cp/config/config.php`에서 이미 `base_url` 설정하므로 실행되지 않아야 함

**확인 필요**: Config 클래스가 로드되기 전에 `is_https()`가 호출되는지 확인

### 3. JavaScript 리다이렉트
**확인 필요**: 뷰 파일에서 `location.href` 또는 `window.location` 사용 여부
- 현재까지 확인한 결과: JavaScript 리다이렉트 없음 (단순 `javascript:void(0)` 사용)

## 🧪 테스트 방법

### 1. 테스트 파일 실행
```
http://192.168.0.24:8090/test_https_check.php
```
이 파일을 통해 실제 `$_SERVER` 변수 값들을 확인할 수 있습니다.

### 2. 브라우저 개발자 도구 확인
1. 크롬 개발자 도구 열기 (F12)
2. Network 탭 열기
3. `http://192.168.0.24:8090/auth/login` 접속
4. 리다이렉트가 발생하는지 확인
5. 리다이렉트가 발생한다면:
   - 어떤 URL로 리다이렉트되는지 확인
   - Response Headers에서 `Location` 헤더 확인
   - Status Code 확인 (301, 302, 307 등)

### 3. 시크릿 모드 테스트
- 시크릿 모드에서 접속하여 HSTS 캐시 영향 제거

## 📋 체크리스트

- [ ] 크롬 HSTS 캐시 삭제
- [ ] 시크릿 모드에서 테스트
- [ ] 다른 브라우저에서 테스트 (Firefox, Safari, Edge)
- [ ] `test_https_check.php` 실행하여 `$_SERVER` 변수 확인
- [ ] 브라우저 개발자 도구 Network 탭에서 리다이렉트 확인
- [ ] Nginx 로그 확인 (`/var/log/nginx/error_gomgiftnet.log`)

## 🎯 결론

### ✅ 서버 측 확인 결과

**curl 테스트 결과:**
```
Location: http://192.168.0.24:8090/auth/login
HTTP/1.1 307 Temporary Redirect
```

**서버는 정상적으로 HTTP로 리다이렉트하고 있습니다!**

- ✅ Nginx에서 HTTPS 리다이렉트 없음
- ✅ CodeIgniter에서 8090 포트에 대해 HTTP 강제 설정
- ✅ `.htaccess`에서 HTTPS 리다이렉트 없음
- ✅ `redirect()` 함수가 HTTP URL 생성 확인

### 🔴 문제 원인: 브라우저 HSTS 캐시

**확인된 사실:**
- 서버는 HTTP로 정상 리다이렉트 (`Location: http://192.168.0.24:8090/auth/login`)
- 브라우저가 HTTP 리다이렉트를 받아도 자동으로 HTTPS로 변환
- Nginx 로그에서 TLS/SSL 핸드셰이크 시도 확인 (`\x16\x03\x01...`)

**해결 방법:**
1. 크롬 주소창에 `chrome://net-internals/#hsts` 입력
2. "Delete domain security policies"에서 `192.168.0.24` 입력 후 삭제
3. "Query HSTS/PKP domain"에서 `192.168.0.24` 입력하여 삭제 확인
4. 크롬 완전 종료 후 재시작
5. 시크릿 모드에서 테스트 (HSTS 캐시 없음)

