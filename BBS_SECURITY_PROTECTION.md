# BBS 폴더 보안 보호 조치

## 개요
`tb_form_request` 테이블에 대한 무단 데이터 삽입 공격을 차단하기 위한 보안 조치입니다.

---

## 구현된 보안 조치

### 1. 보안 모듈 생성 (`lib/security_form_protection.php`)
- `tb_form_request` 테이블 접근 제어
- 허용된 스크립트만 접근 가능하도록 제한
- SQL 쿼리 실행 전 검증

### 2. `common.php`에 보안 모듈 통합
- 모든 페이지에서 자동으로 보안 모듈 로드
- `tb_form_request` 테이블 보호 활성화

### 3. `sql_query` 함수 보안 강화 (`lib/common.lib.php`)
- SQL 쿼리 실행 전 `tb_form_request` 테이블 접근 검증
- 허용되지 않은 경로에서의 접근 차단

### 4. `bbs/write_update.php` 보안 체크
- 게시글 작성 시 `tb_form_request` 테이블 접근 차단
- 허용된 스크립트만 접근 가능

---

## 허용된 접근 경로

다음 스크립트만 `tb_form_request` 테이블에 접근할 수 있습니다:

1. `/api/case_inquiry.php` - 사례 문의 API
2. `/api/consultation_room_create.php` - 상담방 생성 API
3. `/form/form_write.php` - 폼 작성 처리

**차단되는 경로:**
- `/bbs/write_update.php` - 게시판 글 작성 (차단)
- `/bbs/*` - 기타 BBS 폴더의 모든 스크립트 (차단)
- 기타 모든 직접 접근 (차단)

---

## 보안 기능

### 1. 테이블 접근 제어
```php
protect_tb_form_request($table_name)
```
- 허용되지 않은 스크립트에서 `tb_form_request` 접근 시 차단
- IP 차단 및 보안 로그 기록

### 2. SQL 쿼리 검증
```php
validate_sql_before_execution($sql)
```
- INSERT/UPDATE/DELETE 쿼리 실행 전 검증
- 허용되지 않은 경로에서의 쿼리 실행 차단

### 3. 폼 데이터 검증
```php
validate_form_data_security($data, $table_name)
```
- 스팸 키워드 검사
- SQL Injection 패턴 검사

---

## 차단 시 동작

1. **IP 차단**: 24시간 자동 차단
2. **보안 로그 기록**: 모든 시도 기록
3. **에러 메시지**: "잘못된 접근입니다" 표시

---

## 테스트 방법

### 정상 접근 테스트
```bash
# 허용된 경로 (정상 작동)
POST /api/case_inquiry.php
POST /form/form_write.php
```

### 차단 테스트
```bash
# 차단되는 경로 (차단됨)
POST /bbs/write_update.php?bo_table=test&write_table=tb_form_request
```

---

## 주의사항

1. **기존 기능 영향 없음**: 허용된 경로는 정상 작동
2. **앱 연동 영향 없음**: API 경로는 모두 허용됨
3. **로그 모니터링**: 보안 로그를 정기적으로 확인하여 정상 사용자 차단 여부 확인

---

## 보안 로그 확인

보안 이벤트는 다음 테이블에 기록됩니다:
- `g5_api_security_log` - 모든 보안 이벤트
- `g5_api_blocked_ips` - 차단된 IP 목록

로그 확인 쿼리:
```sql
SELECT * FROM g5_api_security_log 
WHERE event_type LIKE '%tb_form_request%' 
ORDER BY created_at DESC 
LIMIT 100;
```

