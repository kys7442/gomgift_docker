# 폐쇄몰 시스템 완전 가이드

> **작성일**: 2025-12-31  
> **최종 수정**: 2026-01-02  
> **프로젝트**: yc_gomgift 폐쇄몰/복지몰 시스템  
> **목적**: 일반몰과 독립적으로 운영되는 폐쇄몰 시스템 구축

---

## 📋 목차

### Part 1: 시스템 개요
1. [프로젝트 개요](#프로젝트-개요)
2. [현재 구조 분석](#현재-구조-분석)
3. [문제점 및 요구사항](#문제점-및-요구사항)

### Part 2: 독립 운영 구조 설계
4. [해결 방안 분석](#해결-방안-분석)
5. [최종 권장 방안](#최종-권장-방안)
6. [데이터베이스 스키마](#데이터베이스-스키마)

### Part 3: 전체 개발 로드맵
7. [Phase 0: 관리자 페이지](#phase-0-관리자-페이지)
8. [Phase 1: 카테고리 독립화](#phase-1-카테고리-독립화)
9. [Phase 2: 권한 시스템](#phase-2-권한-시스템)
10. [Phase 3: 상품 진열 페이지](#phase-3-상품-진열-페이지)
11. [Phase 4: 상품 상세 페이지](#phase-4-상품-상세-페이지)
12. [Phase 5: 장바구니](#phase-5-장바구니)
13. [Phase 6: 주문정보 입력](#phase-6-주문정보-입력)
14. [Phase 7: 결제 진행](#phase-7-결제-진행)
15. [Phase 8: 주문 완료](#phase-8-주문-완료)
16. [Phase 9: 폐쇄몰별 가격 테이블](#phase-9-폐쇄몰별-가격-테이블)
17. [Phase 10: 공통 수정사항](#phase-10-공통-수정사항)
18. [Phase 11: 테스트 및 검증](#phase-11-테스트-및-검증)

### Part 4: 구현 가이드
19. [구현 우선순위](#구현-우선순위)
20. [파일 구조](#파일-구조)
21. [주의사항](#주의사항)

---

# Part 1: 시스템 개요

## 프로젝트 개요

### 핵심 목표
특정 권한이 있는 회원만 구매할 수 있는 **폐쇄몰/복지몰 시스템** 구축하되, **일반몰과 완전히 독립적으로 운영**

### 핵심 요구사항

#### 기본 기능
- ✅ 특정 권한 회원만 접근 가능 (레벨/회원/입장코드)
- ✅ UI는 기존과 동일, 가격 표시/결제금액만 차이
- ✅ `it_aov_use` 무시, `it_price`만 사용
- ✅ 선택옵션, 추가옵션은 영카트 기본 로직 사용
- ✅ 관리자 페이지에서 폐쇄몰 설정 및 관리 가능

#### 독립 운영 요구사항 (신규)
- ✅ **카테고리 독립**: 일반몰과 폐쇄몰 카테고리 분리 (CM 접두사)
- ✅ **가격 정책 독립**: 폐쇄몰별 독립적인 가격/배송비 설정
- ✅ **상호 비가시성**: 일반몰에서 폐쇄몰 카테고리 숨김, 반대도 동일

#### 플로우
```
상품목록 → 상품상세 → 장바구니/바로구매 → 주문정보 입력 → 결제 → 주문완료
```

---

## 현재 구조 분석

### 폐쇄몰 데이터 구조

#### 주요 테이블
- **폐쇄몰 관리**: `gom_mall_closed_malls`
- **카테고리**: `g5_shop_category` (일반몰과 공유 ⚠️)
- **상품**: `g5_shop_item` (일반몰과 공유 ⚠️)

#### 상품 진열 방식 (`cm_product_type`)
```
┌─────────────┬──────────────────────────────────┐
│ 타입        │ 설명                             │
├─────────────┼──────────────────────────────────┤
│ all         │ 전체 상품 (it_use='1')           │
│ category    │ 특정 카테고리 선택               │
│ item        │ 개별 상품코드 지정               │
│ partner     │ 파트너사별 상품                  │
└─────────────┴──────────────────────────────────┘
```

#### 가격 표시 방식 (`cm_price_display_type`)
```
┌─────────────┬──────────────────────────────────┐
│ 타입        │ 설명                             │
├─────────────┼──────────────────────────────────┤
│ purchase    │ 매입가(it_price) 사용            │
│ margin      │ 마진율가(it_price2) 사용         │
│ aov         │ 객단가 사용                      │
└─────────────┴──────────────────────────────────┘
```

#### 폐쇄몰 독립 설정
- **할인률**: `cm_discount_rate` (0~100%)
- **원단위 처리**: `cm_price_round_unit` (10/100/1000원 단위 올림)

### 현재 공유되는 요소 (문제점)

> ⚠️ **문제**: 일반몰 변경 시 폐쇄몰에 영향

- ❌ 카테고리 테이블 (일반몰과 동일)
- ❌ 상품 테이블 (일반몰과 동일)
- ❌ 가격 정보 (it_price, it_price2, AOV 가격)
- ❌ 배송비 정책 (상품의 배송비 설정)

---

## 문제점 및 요구사항

### 현재 문제점

#### 1. 카테고리 혼재
- 일반몰과 폐쇄몰 카테고리가 구분되지 않음
- 관리자 페이지에서 모두 섞여서 표시
- 카테고리 관리 시 혼란 발생

#### 2. 가격 정책 공유
- 일반몰 상품 가격 변경 시 폐쇄몰에도 즉시 영향
- 폐쇄몰별 독립적인 가격 설정 불가
- 폐쇄몰마다 다른 가격 정책 적용 불가

#### 3. 배송비 정책 공유
- 상품의 배송비 변경 시 모든 폐쇄몰에 영향
- 폐쇄몰별 배송비 정책 불가

### 해결 요구사항

#### 1. 폐쇄몰 전용 카테고리 자동 생성
- CM 접두사로 시작하는 카테고리 자동 생성
- 예: `CM10`, `CM11`, `CM12`
- 카테고리 생성 시 자동으로 접두사 부여

#### 2. 카테고리 상호 비가시성
- 일반몰에서 폐쇄몰 카테고리 숨김
- 폐쇄몰에서 일반몰 카테고리 숨김
- 관리자 페이지에서 필터링 가능

#### 3. 상품 복사 + 폐쇄몰별 가격 테이블
- 일반몰 상품을 폐쇄몰 전용으로 복사 (선택사항)
- 폐쇄몰별 가격/배송비 독립 관리 (필수)

---

# Part 2: 독립 운영 구조 설계

## 해결 방안 분석

### 방안 1: 폐쇄몰 전용 카테고리 생성 ⭐ 추천

#### 개념
폐쇄몰 전용 카테고리를 별도로 생성하여 사용

#### 장점
- ✅ 기존 구조 변경 최소화
- ✅ 카테고리 관리 독립성 확보
- ✅ 일반몰과 명확한 구분
- ✅ 검색/필터링 용이 (`ca_id LIKE 'CM%'`)

#### 단점
- ⚠️ 카테고리 중복 관리 필요
- ⚠️ 카테고리 수 증가

#### 구현 방법
```
1. 폐쇄몰 전용 카테고리 코드 규칙 설정
   - CM 접두사 사용: CM10, CM11, CM12
   
2. 카테고리 생성 시 자동 접두사 부여
   - 폐쇄몰 전용 옵션 선택 시 CM 자동 추가
   
3. 카테고리 ID 검증 로직 수정
   - 숫자만 → 숫자 또는 CM+숫자
```

#### 변경 범위
- **난이도**: 중간
- **파일 수**: 5-7개
- **예상 시간**: 2-3일

---

### 방안 2: 상품 복사 기능 (선택사항)

#### 개념
일반몰 상품을 복사하여 폐쇄몰 전용 상품으로 생성

#### 장점
- ✅ 완전한 독립성 (가격, 옵션, 배송비 등)
- ✅ 일반몰 변경이 폐쇄몰에 영향 없음
- ✅ 폐쇄몰별 상품 정보 커스터마이징 가능

#### 단점
- ⚠️ 상품 데이터 중복
- ⚠️ 재고 관리 복잡도 증가
- ⚠️ 상품 수정 시 양쪽 모두 수정 필요

#### 구현 방법
```
1. 상품 복사 기능 구현
   - 복사된 상품 ID: 원본ID_CM폐쇄몰ID
   - 예: PROD001_CM1
   
2. 복사 시 카테고리 자동 변경
   - 폐쇄몰 전용 카테고리로 배치
   
3. 폐쇄몰 설정에서 선택
   - 카테고리 또는 상품코드 선택
```

#### 변경 범위
- **난이도**: 중간
- **파일 수**: 3-4개
- **예상 시간**: 1-2일

---

### 방안 3: 폐쇄몰별 가격/정책 테이블 ⭐⭐ 강력 추천

#### 개념
폐쇄몰별 상품 가격 및 정책을 별도 테이블로 관리

#### 장점
- ✅ 상품 데이터 중복 없음
- ✅ 폐쇄몰별 유연한 가격 정책
- ✅ 확장성 우수
- ✅ 재고는 원본과 공유 가능
- ✅ 장기적으로 최적의 구조

#### 단점
- ⚠️ 새로운 테이블 및 관계 설정 필요
- ⚠️ 조회 쿼리 복잡도 증가 (LEFT JOIN)
- ⚠️ 구현 난이도 높음

#### 동작 방식
```
폐쇄몰 상품 조회 시:
1. gom_mall_closed_mall_item_override 테이블 먼저 확인
2. 해당 폐쇄몰+상품 조합이 있으면 → 오버라이드 값 사용
3. 없으면 → 원본 상품 정보 사용

가격 계산 우선순위:
cmio_price (폐쇄몰 전용) > it_price (원본)
cmio_price2 (폐쇄몰 전용) > it_price2 (원본)

배송비 계산 우선순위:
cmio_sc_* (폐쇄몰 전용) > it_sc_* (원본)
```

#### 변경 범위
- **난이도**: 큼
- **파일 수**: 15-20개
- **예상 시간**: 5-7일

---

## 최종 권장 방안

### 🎯 통합 방안: 3단계 접근

#### 권장 이유
1. **Phase 1 (카테고리 독립화)**: 즉시 효과, 변경 범위 작음
2. **Phase 9 (가격 테이블)**: 장기적으로 최적, 확장성 우수
3. **상품 복사**: 선택사항 (필요 시에만)

#### 구현 순서
```
Phase 0: 관리자 페이지 (기본 폐쇄몰 관리)
  ↓
Phase 1: 카테고리 독립화 (CM 접두사)
  ↓
Phase 2~8: 기본 플로우 (권한, 상품, 장바구니, 결제)
  ↓
Phase 9: 폐쇄몰별 가격 테이블 (독립 운영 완성)
  ↓
Phase 10~11: 공통 수정 및 테스트
```

---

## 데이터베이스 스키마

### 1. 폐쇄몰 관리 테이블

```sql
CREATE TABLE IF NOT EXISTS `gom_mall_closed_malls` (
  `cm_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '폐쇄몰 관리번호',
  `cm_title` VARCHAR(255) NOT NULL DEFAULT '' COMMENT '폐쇄몰 제목',
  `cm_use` ENUM('Y','N') NOT NULL DEFAULT 'N' COMMENT '사용 여부',
  `cm_start_date` DATETIME DEFAULT NULL COMMENT '운영 시작일시',
  `cm_end_date` DATETIME DEFAULT NULL COMMENT '운영 종료일시',
  `cm_access_type` ENUM('member','level','code') NOT NULL DEFAULT 'level' COMMENT '접근 권한 타입',
  `cm_access_members` TEXT COMMENT '접근 가능 회원 목록 (JSON)',
  `cm_access_levels` TEXT COMMENT '접근 가능 레벨 목록 (JSON)',
  `cm_access_code` VARCHAR(50) DEFAULT NULL COMMENT '입장 코드',
  `cm_product_type` ENUM('category','item','partner') NOT NULL DEFAULT 'category' COMMENT '진열 상품 타입',
  `cm_product_categories` TEXT COMMENT '카테고리 목록 (JSON)',
  `cm_product_items` TEXT COMMENT '상품코드 목록 (JSON)',
  `cm_product_partners` TEXT COMMENT '파트너사 코드 목록 (JSON)',
  `cm_banner_image` VARCHAR(255) DEFAULT NULL COMMENT '타이틀 이미지/배너',
  `cm_skin` VARCHAR(100) NOT NULL DEFAULT 'list.10.skin.php' COMMENT '사용할 스킨',
  `cm_payment_methods` TEXT COMMENT '결제 수단 (JSON)',
  `cm_pagination_type` ENUM('more','paging') NOT NULL DEFAULT 'paging' COMMENT '페이징 타입',
  `cm_price_display_type` ENUM('purchase','margin','aov') NOT NULL DEFAULT 'purchase' COMMENT '가격 표시 방식',
  `cm_discount_rate` DECIMAL(5,2) DEFAULT '0.00' COMMENT '할인률 (%)',
  `cm_price_round_unit` INT(11) DEFAULT '0' COMMENT '원단위 처리 (0/10/100/1000)',
  `cm_reg_time` DATETIME NOT NULL COMMENT '등록일시',
  `cm_update_time` DATETIME DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`cm_id`),
  KEY `idx_cm_use` (`cm_use`),
  KEY `idx_cm_dates` (`cm_start_date`, `cm_end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='폐쇄몰 관리';
```

### 2. 폐쇄몰별 상품 오버라이드 테이블 (신규)

```sql
CREATE TABLE `gom_mall_closed_mall_item_override` (
  `cmio_id` INT(11) NOT NULL AUTO_INCREMENT COMMENT '오버라이드 ID',
  `cm_id` INT(11) NOT NULL COMMENT '폐쇄몰 ID',
  `it_id` VARCHAR(20) NOT NULL COMMENT '상품 ID',
  
  -- 가격 정보 (NULL이면 원본 상품 가격 사용)
  `cmio_price` INT(11) NULL DEFAULT NULL COMMENT '폐쇄몰 전용 가격 (it_price 대체)',
  `cmio_price2` INT(11) NULL DEFAULT NULL COMMENT '폐쇄몰 전용 마진가 (it_price2 대체)',
  `cmio_cust_price` INT(11) NULL DEFAULT NULL COMMENT '폐쇄몰 전용 정가',
  
  -- 배송비 정보 (NULL이면 원본 상품 배송비 사용)
  `cmio_sc_type` TINYINT(4) NULL DEFAULT NULL COMMENT '배송비 타입 (0:무료, 1:착불, 2:선불)',
  `cmio_sc_method` TINYINT(4) NULL DEFAULT NULL COMMENT '배송비 부과 방식',
  `cmio_sc_price` INT(11) NULL DEFAULT NULL COMMENT '기본 배송비',
  `cmio_sc_minimum` INT(11) NULL DEFAULT NULL COMMENT '무료배송 최소금액',
  
  -- 할인 정보 (NULL이면 폐쇄몰 기본 할인률 사용)
  `cmio_discount_rate` DECIMAL(5,2) NULL DEFAULT NULL COMMENT '폐쇄몰 전용 할인률 (%)',
  
  -- 재고 정보 (선택사항, NULL이면 원본 재고 사용)
  `cmio_stock_qty` INT(11) NULL DEFAULT NULL COMMENT '폐쇄몰 전용 재고',
  
  -- 기타
  `cmio_use` ENUM('Y','N') NOT NULL DEFAULT 'Y' COMMENT '사용 여부',
  `cmio_reg_time` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '등록일시',
  `cmio_update_time` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '수정일시',
  
  PRIMARY KEY (`cmio_id`),
  UNIQUE KEY `uk_cm_item` (`cm_id`, `it_id`),
  KEY `idx_cm_id` (`cm_id`),
  KEY `idx_it_id` (`it_id`),
  KEY `idx_use` (`cmio_use`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='폐쇄몰별 상품 가격/정책 오버라이드';
```

---

# Part 3: 전체 개발 로드맵

## Phase 0: 관리자 페이지

> **우선순위**: 🔴 최우선 (모든 사용자 페이지의 기반)

### 0.1 데이터베이스 테이블 생성
- [ ] `gom_mall_closed_malls` 테이블 생성 (위 스키마 참조)
- [ ] 테이블 생성 스크립트: `adm/shop_admin/closedmall_table_create.php`

### 0.2 관리자 메뉴 추가
- [ ] `adm/admin.menu500.shop_2of2.php` 수정
  - 이벤트관리(`500300`) 아래에 폐쇄몰 관리 메뉴 추가
  - 메뉴 코드: `500320`
  - 파일 경로: `adm/shop_admin/closedmalllist.php`

### 0.3 폐쇄몰 목록 페이지
- [ ] `adm/shop_admin/closedmalllist.php` 생성
  - 폐쇄몰 목록 표시
  - 제목, 사용여부, 운영기간, 관리 버튼
  - 이벤트 관리 페이지 참고

### 0.4 폐쇄몰 등록/수정 페이지
- [ ] `adm/shop_admin/closedmallform.php` 생성
  - 모든 설정 항목 입력 가능
  - **CM 카테고리 생성 옵션 추가** (Phase 1 연동)

#### 설정 항목
1. **기본 정보**
   - 제목, 사용여부

2. **운영 기간**
   - 시작일시, 종료일시, 무제한 옵션

3. **접근 권한**
   - 회원 선택 / 레벨 선택 / 입장 코드

4. **진열 상품**
   - 카테고리 / 상품코드 / 파트너사
   - **카테고리 선택 시 CM 카테고리만 표시** (Phase 1 연동)

5. **타이틀 이미지**
   - 파일 업로드, 미리보기

6. **스킨 선택**
   - 드롭다운: `theme/kiwi/skin/shop/basic/` 내 스킨

7. **가격 표시 방식** (신규)
   - 매입가 / 마진가 / 객단가

8. **할인률 및 원단위 처리** (신규)
   - 할인률 (0~100%)
   - 원단위 처리 (0/10/100/1000)

9. **결제 수단**
   - 무통장, 카드, 계좌이체, 가상계좌, 휴대폰, 쿠폰, 포인트

10. **페이징 타입**
    - 더보기 / 페이징

### 0.5 폐쇄몰 저장/수정 처리
- [ ] `adm/shop_admin/closedmallformupdate.php` 생성
  - 데이터 저장/수정
  - 파일 업로드 처리
  - JSON 직렬화
  - 유효성 검증

### 0.6 폐쇄몰 삭제 기능
- [ ] 체크박스 선택 후 일괄 삭제
- [ ] 개별 삭제

### 0.7 AJAX 유틸리티 (선택사항)
- [ ] 상품 검색 AJAX
- [ ] 회원 검색 AJAX
- [ ] 파트너사 검색 AJAX

---

## Phase 1: 카테고리 독립화

> **우선순위**: 🔴 최우선 (Phase 0 직후)  
> **예상 시간**: 3일

### 1.1 카테고리 코드 규칙 정의

```
폐쇄몰 전용 카테고리:
- 1차: CM10, CM11, CM12, ...
- 2차: CM1001, CM1002, ...
- 3차: CM100101, CM100102, ...

일반몰 카테고리:
- 1차: 10, 11, 12, ...
- 2차: 1001, 1002, ...
- 3차: 100101, 100102, ...
```

### 1.2 카테고리 생성 폼 수정
**파일**: `adm/shop_admin/categoryform.php`

```php
// 폐쇄몰 전용 카테고리 옵션 추가
<tr>
    <th>카테고리 유형</th>
    <td>
        <label>
            <input type="radio" name="ca_type" value="normal" checked>
            일반몰 카테고리
        </label>
        <label>
            <input type="radio" name="ca_type" value="closedmall">
            폐쇄몰 전용 카테고리 (CM 접두사 자동 부여)
        </label>
    </td>
</tr>
```

### 1.3 카테고리 저장 로직 수정
**파일**: `adm/shop_admin/categoryformupdate.php`

```php
// 폐쇄몰 전용 카테고리인 경우 CM 접두사 추가
if ($_POST['ca_type'] == 'closedmall') {
    if (strpos($ca_id, 'CM') !== 0) {
        $ca_id = 'CM' . $ca_id;
    }
}

// 카테고리 ID 검증 (숫자 또는 CM+숫자)
if (!preg_match('/^(CM)?[0-9]+$/', $ca_id)) {
    alert('카테고리 코드는 숫자 또는 CM+숫자 형식이어야 합니다.');
}
```

### 1.4 카테고리 목록 필터링
**파일**: `adm/shop_admin/categorylist.php`

```php
// 필터 옵션 추가
<select name="ca_type_filter">
    <option value="">전체</option>
    <option value="normal">일반몰만</option>
    <option value="closedmall">폐쇄몰만</option>
</select>

// SQL 조건 추가
if ($ca_type_filter == 'normal') {
    $sql_search .= " AND ca_id NOT LIKE 'CM%' ";
} elseif ($ca_type_filter == 'closedmall') {
    $sql_search .= " AND ca_id LIKE 'CM%' ";
}
```

### 1.5 일반몰 상품 목록 필터링
**파일**: `shop/list.php`, `shop/itemlist.php`

```php
// 일반몰에서는 폐쇄몰 카테고리 제외
$sql_search .= " AND ca_id NOT LIKE 'CM%' ";
```

### 변경 파일 목록
1. `adm/shop_admin/categoryform.php`
2. `adm/shop_admin/categoryformupdate.php`
3. `adm/shop_admin/categorylist.php`
4. `shop/list.php`
5. `shop/itemlist.php`

---

## Phase 2: 권한 시스템

> **우선순위**: 🟠 높음

### 2.1 권한 체크 공통 함수 생성
**파일**: `lib/closed_mall.lib.php` (신규)

```php
/**
 * 폐쇄몰 접근 권한 체크
 */
function is_closed_mall_member($cm_id) {
    global $member;
    
    $cm = get_closed_mall($cm_id);
    
    switch ($cm['cm_access_type']) {
        case 'member':
            // 회원 목록 확인
            $members = json_decode($cm['cm_access_members'], true);
            return in_array($member['mb_id'], $members);
            
        case 'level':
            // 레벨 확인
            $levels = json_decode($cm['cm_access_levels'], true);
            return in_array($member['mb_level'], $levels);
            
        case 'code':
            // 입장 코드 확인 (세션)
            return get_session('ss_closed_mall_code_' . $cm_id) == $cm['cm_access_code'];
    }
    
    return false;
}
```

### 2.2 환경 설정
- [ ] `.env` 또는 설정 파일에 폐쇄몰 관련 설정 추가
  - `CLOSED_MALL_ENABLED`: 폐쇄몰 활성화 여부
  - `CLOSED_MALL_AUTH_MENU`: 권한 메뉴 코드

---

## Phase 3: 상품 진열 페이지

> **우선순위**: 🟠 높음

### 3.1 파일 생성
- [ ] `shop/closedmall_list.php` 생성
  - 폐쇄몰 상품 목록 표시
  - CM 카테고리만 표시 (Phase 1 연동)

### 3.2 스킨 파일 생성
- [ ] `theme/kiwi/skin/shop/basic/list.closed.skin.php`
  - 기존 `list.10.skin.php` 복사
  - 가격 표시 로직 수정: `it_price`만 사용

### 3.3 가격 표시 로직
```php
// it_aov_use 체크 제거
// it_price만 표시
$price = $row['it_price'];

// 폐쇄몰 할인률 적용 (Phase 9에서 오버라이드 우선)
if ($cm['cm_discount_rate'] > 0) {
    $price = $price * (1 - $cm['cm_discount_rate'] / 100);
}

// 원단위 처리
if ($cm['cm_price_round_unit'] > 0) {
    $price = ceil($price / $cm['cm_price_round_unit']) * $cm['cm_price_round_unit'];
}
```

### 3.4 권한 체크
```php
// 페이지 상단
if (!is_closed_mall_member($cm_id)) {
    alert('접근 권한이 없습니다.');
}
```

---

## Phase 4: 상품 상세 페이지

> **우선순위**: 🟠 높음

### 4.1 파일 생성
- [ ] `shop/closedmall_item.php` 생성

### 4.2 스킨 파일 생성
- [ ] `theme/kiwi/skin/shop/basic/item.form.closed.skin.php`
  - 기존 `item.form.skin.php` 복사
  - 가격 표시 로직 수정

### 4.3 가격 계산
```php
// 기본 가격
$price = $it['it_price'];

// 옵션 가격은 영카트 기본 로직 사용
// 선택옵션: io_price
// 추가옵션: io_price

// 최종 가격 = it_price + 옵션가격
```

### 4.4 옵션 처리
- [ ] AOV 관련 로직 제거
- [ ] 영카트 기본 옵션 처리만 사용

---

## Phase 5: 장바구니

> **우선순위**: 🟡 중간

### 5.1 파일 수정
- [ ] `shop/closedmall_cart.php` 생성
- [ ] `shop/closedmall_cartupdate.php` 생성

### 5.2 가격 계산
```php
// it_price만 사용
$price = $it['it_price'];

// 옵션 가격 추가
$price += $option_price;

// 폐쇄몰 할인률 적용
if ($cm['cm_discount_rate'] > 0) {
    $price = $price * (1 - $cm['cm_discount_rate'] / 100);
}
```

---

## Phase 6: 주문정보 입력

> **우선순위**: 🟡 중간

### 6.1 파일 수정
- [ ] `shop/closedmall_orderform.php` 생성

### 6.2 가격 계산
```php
// it_price + 옵션가격
$price = $it['it_price'] + $option_price;

// 배송비, 포인트 등은 기존 로직 유지
```

---

## Phase 7: 결제 진행

> **우선순위**: 🟡 중간

### 7.1 결제 프로세스
- [ ] `shop/closedmall_orderformupdate.php` 생성

### 7.2 결제 금액 계산
```php
$total = $it_price + $option_price + $delivery - $point - $coupon;
```

### 7.3 결제 모듈 연동
- [ ] 기존 결제 모듈 그대로 사용
- [ ] 결제 금액만 수정된 값 전달

---

## Phase 8: 주문 완료

> **우선순위**: 🟡 중간

### 8.1 주문 완료 페이지
- [ ] `shop/closedmall_orderinquiryview.php` 생성

### 8.2 주문 내역 표시
- [ ] `it_price` 표시
- [ ] 옵션 가격 표시
- [ ] 총 결제 금액 표시

---

## Phase 9: 폐쇄몰별 가격 테이블

> **우선순위**: 🟠 높음 (장기적 최적 구조)  
> **예상 시간**: 7일

### 9.1 테이블 생성
- [ ] `gom_mall_closed_mall_item_override` 테이블 생성 (위 스키마 참조)
- [ ] 테이블 생성 스크립트: `adm/shop_admin/closedmall_item_override_table_create.php`

### 9.2 상품 조회 쿼리 수정
**파일**: `shop/closedmall_list.php`, `shop/closedmall_item.php`

```php
// LEFT JOIN으로 오버라이드 정보 가져오기
$sql = "SELECT 
    a.*,
    o.cmio_price,
    o.cmio_price2,
    o.cmio_sc_type,
    o.cmio_sc_price,
    o.cmio_discount_rate
FROM g5_shop_item a
LEFT JOIN gom_mall_closed_mall_item_override o 
    ON a.it_id = o.it_id AND o.cm_id = '$cm_id' AND o.cmio_use = 'Y'
WHERE a.it_use = '1'";

// 가격 계산 시 오버라이드 우선 사용
$price = $row['cmio_price'] ?? $row['it_price'];
$price2 = $row['cmio_price2'] ?? $row['it_price2'];
```

### 9.3 가격 계산 함수 추가
**파일**: `lib/closed_mall.lib.php`

```php
/**
 * 폐쇄몰 상품 가격 계산
 * 오버라이드 가격이 있으면 우선 사용
 */
function get_closedmall_item_price($cm_id, $it_id, $price_type = 'price') {
    // 오버라이드 정보 조회
    $override = sql_fetch("
        SELECT * FROM gom_mall_closed_mall_item_override 
        WHERE cm_id = '$cm_id' AND it_id = '$it_id' AND cmio_use = 'Y'
    ");
    
    // 원본 상품 정보 조회
    $item = get_shop_item($it_id);
    
    // 가격 우선순위: 오버라이드 > 원본
    $field_map = [
        'price' => 'cmio_price',
        'price2' => 'cmio_price2',
        'cust_price' => 'cmio_cust_price'
    ];
    
    $override_field = $field_map[$price_type];
    $original_field = 'it_' . $price_type;
    
    return $override[$override_field] ?? $item[$original_field];
}
```

### 9.4 관리자 UI 추가
**파일**: `adm/shop_admin/closedmall_item_price_form.php` (신규)

```php
// 폐쇄몰별 상품 가격 설정 폼
<form method="post" action="./closedmall_item_price_update.php">
    <input type="hidden" name="cm_id" value="<?php echo $cm_id; ?>">
    <input type="hidden" name="it_id" value="<?php echo $it_id; ?>">
    
    <table>
        <tr>
            <th>폐쇄몰 전용 가격</th>
            <td>
                <input type="number" name="cmio_price" 
                       value="<?php echo $override['cmio_price']; ?>"
                       placeholder="비워두면 원본 가격 사용">
            </td>
        </tr>
        <tr>
            <th>폐쇄몰 전용 마진가</th>
            <td>
                <input type="number" name="cmio_price2" 
                       value="<?php echo $override['cmio_price2']; ?>"
                       placeholder="비워두면 원본 마진가 사용">
            </td>
        </tr>
        <tr>
            <th>배송비 타입</th>
            <td>
                <select name="cmio_sc_type">
                    <option value="">원본 사용</option>
                    <option value="0">무료</option>
                    <option value="1">착불</option>
                    <option value="2">선불</option>
                </select>
            </td>
        </tr>
        <tr>
            <th>폐쇄몰 전용 할인률</th>
            <td>
                <input type="number" name="cmio_discount_rate" 
                       value="<?php echo $override['cmio_discount_rate']; ?>"
                       placeholder="비워두면 폐쇄몰 기본 할인률 사용"
                       step="0.01" min="0" max="100">
            </td>
        </tr>
    </table>
    
    <button type="submit">저장</button>
</form>
```

### 9.5 가격 저장 처리
**파일**: `adm/shop_admin/closedmall_item_price_update.php` (신규)

### 변경 파일 목록
1. `adm/shop_admin/closedmall_item_override_table_create.php` (신규)
2. `adm/shop_admin/closedmall_item_price_form.php` (신규)
3. `adm/shop_admin/closedmall_item_price_update.php` (신규)
4. `shop/closedmall_list.php` (수정)
5. `shop/closedmall_item.php` (수정)
6. `shop/closedmall_cart.php` (수정)
7. `shop/closedmall_orderform.php` (수정)
8. `lib/closed_mall.lib.php` (함수 추가)

---

## Phase 10: 공통 수정사항

> **우선순위**: 🟢 낮음

### 10.1 AJAX 가격 계산
- [ ] 상품 상세 페이지 실시간 가격 계산
- [ ] AOV 관련 JavaScript 제거
- [ ] `it_price + 옵션가격` 계산

### 10.2 주문 조회 페이지
- [ ] `shop/closedmall_orderinquiry.php` 확인
- [ ] 가격 표시 로직 수정

---

## Phase 11: 테스트 및 검증

> **우선순위**: 🟢 낮음

### 11.1 기능 테스트
- [ ] 권한 없는 회원 접근 차단 확인
- [ ] 권한 있는 회원 정상 접근 확인
- [ ] CM 카테고리 생성 및 필터링 확인
- [ ] 상품 목록 가격 표시 확인
- [ ] 상품 상세 가격 표시 확인
- [ ] 옵션 선택 및 가격 계산 확인
- [ ] 장바구니 가격 계산 확인
- [ ] 주문서 가격 계산 확인
- [ ] 결제 금액 확인
- [ ] 주문 완료 후 내역 확인
- [ ] 폐쇄몰별 가격 오버라이드 확인

### 11.2 통합 테스트
- [ ] 전체 플로우 테스트
- [ ] 다양한 옵션 조합 테스트
- [ ] 에러 케이스 테스트

### 11.3 성능 테스트
- [ ] 페이지 로딩 속도 확인
- [ ] 데이터베이스 쿼리 최적화

---

# Part 4: 구현 가이드

## 구현 우선순위

### 🔴 최우선 (필수 선행)
1. **Phase 0**: 관리자 페이지 (3일)
2. **Phase 1**: 카테고리 독립화 (3일)

### 🟠 높음
3. **Phase 2**: 권한 시스템 (2일)
4. **Phase 3**: 상품 진열 (2일)
5. **Phase 4**: 상품 상세 (2일)

### 🟡 중간
6. **Phase 5**: 장바구니 (2일)
7. **Phase 6**: 주문정보 입력 (2일)
8. **Phase 7**: 결제 진행 (2일)
9. **Phase 8**: 주문 완료 (1일)

### 🟠 높음 (장기 최적화)
10. **Phase 9**: 폐쇄몰별 가격 테이블 (7일)

### 🟢 낮음
11. **Phase 10**: 공통 수정 (2일)
12. **Phase 11**: 테스트 (3일)

---

## 총 예상 일정

### 최소 구성 (Phase 0~8)
```
Phase 0: 3일
Phase 1: 3일
Phase 2~8: 13일
─────────────
총: 19일 (약 4주)
```

### 완전 구성 (Phase 0~11)
```
Phase 0~8: 19일
Phase 9: 7일
Phase 10~11: 5일
─────────────
총: 31일 (약 6주)
```

---

## 파일 구조

```
adm/shop_admin/
  ├── closedmalllist.php                    (신규 - 폐쇄몰 목록)
  ├── closedmallform.php                    (신규 - 폐쇄몰 등록/수정)
  ├── closedmallformupdate.php              (신규 - 폐쇄몰 저장)
  ├── closedmall_table_create.php           (신규 - 테이블 생성)
  ├── closedmall_item_override_table_create.php (신규 - 오버라이드 테이블)
  ├── closedmall_item_price_form.php        (신규 - 가격 설정 폼)
  ├── closedmall_item_price_update.php      (신규 - 가격 저장)
  ├── categoryform.php                      (수정 - CM 카테고리 옵션)
  ├── categoryformupdate.php                (수정 - CM 접두사 처리)
  ├── categorylist.php                      (수정 - 필터링)
  └── ajax_admin_closed_mall_*.php          (신규 - AJAX)

theme/kiwi/skin/shop/basic/
  ├── list.closed.skin.php                  (신규 - 폐쇄몰 목록 스킨)
  └── item.form.closed.skin.php             (신규 - 폐쇄몰 상세 스킨)

shop/
  ├── closedmall.php                        (신규 - 폐쇄몰 진입)
  ├── closedmall_list.php                   (신규 - 상품 목록)
  ├── closedmall_item.php                   (신규 - 상품 상세)
  ├── closedmall_cart.php                   (신규 - 장바구니)
  ├── closedmall_cartupdate.php             (신규 - 장바구니 업데이트)
  ├── closedmall_orderform.php              (신규 - 주문서)
  ├── closedmall_orderformupdate.php        (신규 - 주문 처리)
  ├── closedmall_orderinquiry.php           (신규 - 주문 조회)
  ├── closedmall_orderinquiryview.php       (신규 - 주문 상세)
  ├── list.php                              (수정 - CM 카테고리 제외)
  └── itemlist.php                          (수정 - CM 카테고리 제외)

lib/
  └── closed_mall.lib.php                   (신규 - 공통 함수)
```

---

## 주의사항

### 1. 기존 시스템과의 호환성
- 기존 일반 쇼핑몰 기능은 그대로 유지
- 폐쇄몰은 별도 경로로 구분
- CM 카테고리는 일반몰에서 자동 제외

### 2. 가격 계산 일관성
- 모든 페이지에서 동일한 가격 계산 로직 사용
- Phase 9 이후: 오버라이드 > 폐쇄몰 설정 > 원본 순서
- AOV 관련 코드 완전 제거

### 3. 권한 관리
- 레벨별 권한과 회원별 권한 모두 지원
- 권한 변경 시 즉시 반영
- 모든 페이지에서 권한 체크 필수

### 4. 보안
- 권한 체크는 모든 페이지에서 필수
- URL 직접 접근 차단
- SQL 인젝션 방지

### 5. 카테고리 관리
- CM 접두사는 자동 부여
- 일반몰과 폐쇄몰 카테고리 명확히 구분
- 관리자 페이지에서 필터링 제공

### 6. 가격 오버라이드
- NULL 값은 원본 사용
- 0 값은 0원으로 처리 (무료)
- 우선순위: 상품별 오버라이드 > 폐쇄몰 기본 설정 > 원본

---

## 다음 단계

**Phase 0부터 순차적으로 개발을 진행합니다.**

1. Phase 0 완료 후 Phase 1 (카테고리 독립화) 즉시 진행
2. Phase 1 완료 후 Phase 2~8 (기본 플로우) 진행
3. 기본 플로우 완료 후 Phase 9 (가격 테이블) 진행
4. 전체 완료 후 Phase 10~11 (최적화 및 테스트)

---

**문서 버전**: 2.0  
**최종 수정일**: 2026-01-02  
**작성자**: AI Assistant  
**기반 문서**: CLOSED_MALL_DEVELOPMENT_ROADMAP.md + CLOSEDMALL_INDEPENDENT_OPERATION_PLAN.md
