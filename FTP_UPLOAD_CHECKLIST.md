# FTP 업로드 체크리스트

## 📋 서버에 전송해야 할 파일 목록

이 문서는 보안 강화 작업에서 수정/생성된 모든 파일 목록입니다.

---

## 🆕 새로 생성된 파일 (반드시 업로드 필요)

### 1. API 보안 모듈
```
/api/api_security.php
```
- **경로**: `/api/api_security.php`
- **설명**: API 보안 모듈 (User-Agent 검증, Rate Limiting, 스팸 필터링, IP 차단)
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

### 2. 폼 보안 보호 모듈
```
/lib/security_form_protection.php
```
- **경로**: `/lib/security_form_protection.php`
- **설명**: tb_form_request 테이블 보호 모듈
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

---

## ✏️ 수정된 파일 (기존 파일 덮어쓰기)

### API 폴더 (`/api/`)

#### 1. 공통 파일
```
/api/_common.php
```
- **경로**: `/api/_common.php`
- **변경사항**: 보안 모듈 포함 추가
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

#### 2. 사례 문의 API
```
/api/case_inquiry.php
```
- **경로**: `/api/case_inquiry.php`
- **변경사항**: 보안 체크 추가, 스팸 필터링 강화, 회원/비회원 구분 로직 개선
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

#### 3. 문의 등록 API
```
/api/inquiry_register.php
```
- **경로**: `/api/inquiry_register.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

#### 4. 상담방 생성 API
```
/api/consultation_room_create.php
```
- **경로**: `/api/consultation_room_create.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

#### 5. 상담 메시지 전송 API
```
/api/consultation_message_send.php
```
- **경로**: `/api/consultation_message_send.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

#### 6. 회원가입 API
```
/api/member_register.php
```
- **경로**: `/api/member_register.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

#### 7. 로그인 API
```
/api/member_login.php
```
- **경로**: `/api/member_login.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

#### 8. 관리자 사례 등록 API
```
/api/admin_case_register.php
```
- **경로**: `/api/admin_case_register.php`
- **변경사항**: 보안 체크 추가
- **중요도**: ⭐⭐⭐⭐ (권장)

---

### 폼 폴더 (`/form/`)

#### 9. 폼 작성 처리
```
/form/form_write.php
```
- **경로**: `/form/form_write.php`
- **변경사항**: 보안 체크 추가, 스팸 필터링, SQL Injection 방지
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

---

### BBS 폴더 (`/bbs/`)

#### 10. 게시글 작성/수정
```
/bbs/write_update.php
```
- **경로**: `/bbs/write_update.php`
- **변경사항**: tb_form_request 테이블 접근 차단 로직 추가
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

---

### 라이브러리 폴더 (`/lib/`)

#### 11. 공통 라이브러리
```
/lib/common.lib.php
```
- **경로**: `/lib/common.lib.php`
- **변경사항**: sql_query 함수에 tb_form_request 테이블 보호 로직 추가
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

---

### 루트 폴더 (`/`)

#### 12. 공통 파일
```
/common.php
```
- **경로**: `/common.php`
- **변경사항**: 보안 모듈 자동 로드 추가
- **중요도**: ⭐⭐⭐⭐⭐ (필수)

---

## 📦 업로드 순서 (권장)

### 1단계: 새로 생성된 파일 먼저 업로드
```
1. /api/api_security.php
2. /lib/security_form_protection.php
```

### 2단계: 핵심 파일 업로드
```
3. /common.php
4. /lib/common.lib.php
5. /api/_common.php
```

### 3단계: API 파일 업로드
```
6. /api/case_inquiry.php
7. /api/inquiry_register.php
8. /api/consultation_room_create.php
9. /api/consultation_message_send.php
10. /api/member_register.php
11. /api/member_login.php
12. /api/admin_case_register.php
```

### 4단계: 폼 및 BBS 파일 업로드
```
13. /form/form_write.php
14. /bbs/write_update.php
```

---

## ✅ 업로드 후 확인 사항

### 1. 파일 권한 확인
- PHP 파일: `644` 또는 `755`
- 디렉토리: `755`

### 2. 데이터베이스 테이블 자동 생성 확인
보안 모듈이 자동으로 생성하는 테이블:
- `g5_api_blocked_ips` - 차단된 IP 목록
- `g5_api_rate_limit` - Rate Limiting 기록
- `g5_api_security_log` - 보안 이벤트 로그

### 3. 기능 테스트
- [ ] API 정상 작동 확인
- [ ] 앱 연동 확인
- [ ] 폼 제출 정상 작동 확인
- [ ] 보안 차단 기능 확인

---

## 🚨 주의사항

### 1. 백업 필수
업로드 전에 **반드시 기존 파일을 백업**하세요.

### 2. 순차 업로드
새로 생성된 파일(`api_security.php`, `security_form_protection.php`)을 먼저 업로드한 후, 수정된 파일을 업로드하세요.

### 3. 테스트 환경 권장
가능하면 테스트 서버에서 먼저 테스트한 후 운영 서버에 적용하세요.

### 4. 파일 경로 확인
서버의 실제 경로 구조를 확인하여 올바른 위치에 업로드하세요.

---

## 📝 파일 목록 요약

### 총 파일 수: 14개
- **새로 생성**: 2개
- **수정**: 12개

### 필수 업로드 파일: 7개
1. `/api/api_security.php` (신규)
2. `/lib/security_form_protection.php` (신규)
3. `/common.php`
4. `/lib/common.lib.php`
5. `/api/_common.php`
6. `/api/case_inquiry.php`
7. `/form/form_write.php`
8. `/bbs/write_update.php`

### 권장 업로드 파일: 6개
- 나머지 API 파일들 (보안 체크 추가)

---

## 🔍 업로드 확인 스크립트

업로드 후 다음 PHP 스크립트로 확인할 수 있습니다:

```php
<?php
// upload_check.php
$required_files = [
    'api/api_security.php',
    'lib/security_form_protection.php',
    'common.php',
    'lib/common.lib.php',
    'api/_common.php',
    'api/case_inquiry.php',
    'form/form_write.php',
    'bbs/write_update.php',
];

echo "<h2>파일 업로드 확인</h2>";
foreach ($required_files as $file) {
    $exists = file_exists($file);
    $status = $exists ? '✅ 존재' : '❌ 없음';
    echo "{$file}: {$status}<br>";
}
?>
```

---

## 📞 문제 발생 시

업로드 후 문제가 발생하면:
1. 에러 로그 확인 (`error_log`)
2. 보안 로그 확인 (`g5_api_security_log` 테이블)
3. 파일 권한 확인
4. PHP 버전 확인 (PHP 5.2.17 이상 필요)

