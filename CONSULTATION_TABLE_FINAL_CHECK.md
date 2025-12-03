# 상담하기 API 테이블 사용 최종 점검 보고서

## 점검 일시
2025-01-XX

## 점검 목적
모든 상담하기 관련 API가 `tb_form_request` 테이블을 사용하는지 최종 확인

---

## ✅ 점검 결과

### 상담하기 관련 API (5개)

| API 파일 | 테이블 사용 | 상태 | 비고 |
|---------|-----------|------|------|
| `consultation_room_create.php` | `tb_form_request` | ✅ 정상 | 상담방 생성 |
| `consultation_rooms.php` | `tb_form_request` | ✅ 정상 | 상담방 목록 조회 |
| `consultation_messages.php` | `tb_form_request` | ✅ 정상 | 상담 메시지 조회 |
| `consultation_message_send.php` | `tb_form_request` | ✅ 정상 | 상담 메시지 전송 |
| `case_inquiry.php` | `tb_form_request` | ✅ 수정 완료 | 사례 문의 등록 |

**결론: 모든 상담하기 관련 API가 `tb_form_request` 테이블을 정상적으로 사용하고 있습니다.**

---

## 📋 수정 완료 내역

### case_inquiry.php 수정 사항

**변경 전:**
- 테이블: `g5_write_inquiry` (그누보드 게시판 구조)
- 그누보드 게시판 필드 사용 (`wr_num`, `wr_parent`, `wr_subject` 등)

**변경 후:**
- 테이블: `tb_form_request`
- `tb_form_request` 테이블 구조에 맞게 필드 매핑

**필드 매핑:**
- `category` → `wr_1` (구분/카테고리)
- `title` → `wr_content` 앞에 제목 포함
- `content` → `wr_content` (문의내용)
- `case_id` → `wr_3` (사례 ID)
- `contact` → `wr_tel` (연락처)
- `mb_name` → `wr_name` (회원명 또는 "비회원")
- `mb_email` → `wr_email` (회원 이메일)

---

## 🔍 상세 점검 내용

### 1. consultation_room_create.php
- ✅ 테이블: `tb_form_request`
- ✅ INSERT 쿼리 사용
- ✅ 모든 필드 정상 매핑

### 2. consultation_rooms.php
- ✅ 테이블: `tb_form_request`
- ✅ WHERE 조건: `wr_email = '{$mb_email}'`
- ✅ SELECT 쿼리 사용

### 3. consultation_messages.php
- ✅ 테이블: `tb_form_request`
- ✅ WHERE 조건: `wr_id = {$room_id} AND wr_email = '{$mb_email}'`
- ✅ `wr_content` 필드에서 메시지 조회

### 4. consultation_message_send.php
- ✅ 테이블: `tb_form_request`
- ✅ UPDATE 쿼리 사용
- ✅ `wr_content` 필드에 메시지 추가
- ✅ `wr_update_time` 업데이트

### 5. case_inquiry.php (수정 완료)
- ✅ 테이블: `tb_form_request` (변경됨)
- ✅ INSERT 쿼리 사용
- ✅ `tb_form_request` 테이블 구조에 맞게 필드 매핑

---

## 📊 테이블 사용 현황 요약

### tb_form_request 테이블 사용 API (상담하기)
1. ✅ `consultation_room_create.php` - 상담방 생성
2. ✅ `consultation_rooms.php` - 상담방 목록 조회
3. ✅ `consultation_messages.php` - 상담 메시지 조회
4. ✅ `consultation_message_send.php` - 상담 메시지 전송
5. ✅ `case_inquiry.php` - 사례 문의 등록

### g5_inquiries 테이블 사용 API (일반 문의 - 상담하기와 별개)
1. ✅ `inquiry_register.php` - 문의 등록 (일반 문의)
2. ✅ `inquiry_detail.php` - 문의 상세 조회
3. ✅ `my_inquiries.php` - 내 문의 내역 조회

---

## ✅ 최종 결론

**모든 상담하기 관련 API가 `tb_form_request` 테이블을 정상적으로 사용하고 있습니다.**

- ✅ 상담방 생성: `tb_form_request` 사용
- ✅ 상담방 목록 조회: `tb_form_request` 사용
- ✅ 상담 메시지 조회: `tb_form_request` 사용
- ✅ 상담 메시지 전송: `tb_form_request` 사용
- ✅ 사례 문의 등록: `tb_form_request` 사용 (수정 완료)

**추가 확인 사항:**
- `g5_write_inquiry` 테이블을 사용하는 코드 없음 ✅
- `g5_consultation_rooms` 테이블을 사용하는 코드 없음 ✅
- `g5_consultation_messages` 테이블을 사용하는 코드 없음 ✅

---

## 📝 case_inquiry.php 필드 매핑 상세

### 입력 파라미터 → DB 필드

| 앱 파라미터 | DB 필드 | 설명 | 필수 |
|-----------|---------|------|------|
| `category` | `wr_1` | 구분/카테고리 | ✅ |
| `title` | `wr_content` | 제목 (내용 앞에 포함) | ✅ |
| `content` | `wr_content` | 문의내용 | ✅ |
| `case_id` | `wr_3` | 사례 ID | ❌ |
| `contact` | `wr_tel` | 연락처 | 조건부 |

### 자동 설정 필드

| DB 필드 | 값 | 설명 |
|---------|-----|------|
| `wr_name` | 회원명 또는 "비회원" | 회원/비회원 구분 |
| `wr_email` | 회원 이메일 | 회원인 경우만 |
| `wr_2` | 빈 문자열 | 소구분 |
| `wr_4` ~ `wr_10` | 빈 문자열 | 추가 필드 |
| `wr_agree_1` | 'N' | 개인정보보호정책 동의 (기본값) |
| `wr_datetime` | 현재 시간 | 등록일 (서버 자동) |
| `wr_update_time` | 현재 시간 | 수정일 (서버 자동) |

---

## 🔗 관련 파일

- `/api/consultation_room_create.php` ✅
- `/api/consultation_rooms.php` ✅
- `/api/consultation_messages.php` ✅
- `/api/consultation_message_send.php` ✅
- `/api/case_inquiry.php` ✅ (수정 완료)

---

## ✅ 점검 완료

모든 상담하기 관련 API가 `tb_form_request` 테이블을 사용하도록 수정 완료되었습니다.

