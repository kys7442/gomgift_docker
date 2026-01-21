# 폐쇄몰 독립 운영 구조 설계 문서

> **작성일**: 2025-12-31  
> **프로젝트**: yc_gomgift 폐쇄몰 시스템  
> **목적**: 일반몰과 폐쇄몰의 카테고리/상품/가격 정책 독립 운영

---

## 📋 목차

1. [현재 구조 분석](#현재-구조-분석)
2. [문제점 및 요구사항](#문제점-및-요구사항)
3. [해결 방안 분석](#해결-방안-분석)
4. [최종 권장 방안](#최종-권장-방안)
5. [구현 계획](#구현-계획)
6. [데이터베이스 스키마](#데이터베이스-스키마)
7. [구현 우선순위](#구현-우선순위)

---

## 현재 구조 분석

### 폐쇄몰 데이터 구조

#### 주요 테이블
- **폐쇄몰 관리**: `gom_mall_closed_malls`
- **카테고리**: `g5_shop_category` (일반몰과 공유)
- **상품**: `g5_shop_item` (일반몰과 공유)

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

### 현재 공유되는 요소

> ⚠️ **문제점**: 일반몰 변경 시 폐쇄몰에 영향

- ✅ 카테고리 테이블 (일반몰과 동일)
- ✅ 상품 테이블 (일반몰과 동일)
- ✅ 가격 정보 (it_price, it_price2, AOV 가격)
- ✅ 배송비 정책 (상품의 배송비 설정)

---

## 문제점 및 요구사항

### 현재 문제점

1. **카테고리 혼재**
   - 일반몰과 폐쇄몰 카테고리가 구분되지 않음
   - 관리자 페이지에서 모두 섞여서 표시

2. **가격 정책 공유**
   - 일반몰 상품 가격 변경 시 폐쇄몰에도 영향
   - 폐쇄몰별 독립적인 가격 설정 불가

3. **배송비 정책 공유**
   - 상품의 배송비 변경 시 모든 폐쇄몰에 영향
   - 폐쇄몰별 배송비 정책 불가

### 사용자 요구사항

1. **폐쇄몰 전용 카테고리 자동 생성**
   - CM 접두사로 시작하는 카테고리 자동 생성
   - 예: `CM10`, `CM11`, `CM12`

2. **카테고리 상호 비가시성**
   - 일반몰에서 폐쇄몰 카테고리 숨김
   - 폐쇄몰에서 일반몰 카테고리 숨김
   - 관리자 페이지에서 필터링 가능

3. **상품 복사 + 폐쇄몰별 가격 테이블**
   - 일반몰 상품을 폐쇄몰 전용으로 복사
   - 폐쇄몰별 가격/배송비 독립 관리

---

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

### 방안 2: 상품 복사 + 폐쇄몰 전용 카테고리

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

### 🎯 통합 방안: Phase 1 + Phase 3 조합

#### 권장 이유
1. **Phase 1 (카테고리 독립화)**: 즉시 효과, 변경 범위 작음
2. **Phase 3 (가격 테이블)**: 장기적으로 최적, 확장성 우수
3. **Phase 2 (상품 복사)**: 선택사항 (필요 시에만)

#### 구현 순서
```
1단계: 카테고리 독립화 (즉시)
  ↓
2단계: 폐쇄몰별 가격 테이블 (중기)
  ↓
3단계: 상품 복사 기능 (선택)
```

---

## 구현 계획

### Phase 1: 카테고리 독립화 (즉시 실행 가능)

#### 목표
- CM 접두사 카테고리 생성 기능 추가
- 일반몰/폐쇄몰 카테고리 필터링
- 상호 비가시성 구현

#### 구현 내용

##### 1. 카테고리 코드 규칙
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

##### 2. 카테고리 생성 폼 수정
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

##### 3. 카테고리 저장 로직 수정
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

##### 4. 카테고리 목록 필터링
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

##### 5. 일반몰 상품 목록 필터링
**파일**: `shop/list.php`, `shop/itemlist.php`

```php
// 일반몰에서는 폐쇄몰 카테고리 제외
$sql_search .= " AND ca_id NOT LIKE 'CM%' ";
```

#### 변경 파일 목록
1. `adm/shop_admin/categoryform.php` - 카테고리 생성 폼
2. `adm/shop_admin/categoryformupdate.php` - 카테고리 저장 로직
3. `adm/shop_admin/categorylist.php` - 카테고리 목록
4. `shop/list.php` - 일반몰 상품 목록
5. `shop/itemlist.php` - 상품 검색

#### 예상 작업 시간
- **개발**: 2일
- **테스트**: 1일
- **총**: 3일

---

### Phase 2: 상품 복사 기능 (선택사항)

#### 목표
- 일반몰 상품을 폐쇄몰 전용으로 복사
- 복사 시 카테고리 자동 변경

#### 구현 내용

##### 1. 상품 복사 버튼 추가
**파일**: `adm/shop_admin/itemlist.php`

```php
// 상품 목록에 복사 버튼 추가
<a href="./itemcopy.php?it_id=<?php echo $row['it_id']; ?>" 
   class="btn btn_03">
   폐쇄몰용 복사
</a>
```

##### 2. 상품 복사 처리
**파일**: `adm/shop_admin/itemcopy.php` (신규 생성)

```php
// 원본 상품 조회
$original = sql_fetch("SELECT * FROM g5_shop_item WHERE it_id = '$it_id'");

// 새 상품 ID 생성
$new_it_id = $it_id . '_CM' . $cm_id;

// 상품 복사
$sql = "INSERT INTO g5_shop_item 
        (it_id, ca_id, it_name, it_price, ...)
        VALUES 
        ('$new_it_id', '$cm_category', ...)";
sql_query($sql);
```

#### 변경 파일 목록
1. `adm/shop_admin/itemlist.php` - 복사 버튼 추가
2. `adm/shop_admin/itemcopy.php` - 복사 처리 (신규)

#### 예상 작업 시간
- **개발**: 1일
- **테스트**: 1일
- **총**: 2일

---

### Phase 3: 폐쇄몰별 가격/정책 테이블 (핵심)

#### 목표
- 폐쇄몰별 상품 가격/배송비 독립 관리
- 상품 중복 없이 정책만 오버라이드

#### 구현 내용

##### 1. 테이블 생성
**파일**: `adm/shop_admin/closedmall_item_override_table_create.php` (신규)

테이블 스키마는 [데이터베이스 스키마](#데이터베이스-스키마) 섹션 참조

##### 2. 상품 조회 쿼리 수정
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
    ON a.it_id = o.it_id AND o.cm_id = '$cm_id'
WHERE a.it_use = '1'";

// 가격 계산 시 오버라이드 우선 사용
$price = $row['cmio_price'] ?? $row['it_price'];
$price2 = $row['cmio_price2'] ?? $row['it_price2'];
```

##### 3. 가격 계산 로직 수정
**파일**: `lib/closed_mall.lib.php` (신규 함수 추가)

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

##### 4. 관리자 UI 추가
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
    </table>
    
    <button type="submit">저장</button>
</form>
```

#### 변경 파일 목록
1. `adm/shop_admin/closedmall_item_override_table_create.php` - 테이블 생성 (신규)
2. `shop/closedmall_list.php` - 상품 목록 쿼리 수정
3. `shop/closedmall_item.php` - 상품 상세 쿼리 수정
4. `shop/closedmall_cart.php` - 장바구니 가격 계산 수정
5. `shop/closedmall_orderform.php` - 주문서 가격 계산 수정
6. `lib/closed_mall.lib.php` - 가격 계산 함수 추가
7. `adm/shop_admin/closedmall_item_price_form.php` - 가격 설정 폼 (신규)
8. `adm/shop_admin/closedmall_item_price_update.php` - 가격 저장 처리 (신규)

#### 예상 작업 시간
- **개발**: 5일
- **테스트**: 2일
- **총**: 7일

---

## 데이터베이스 스키마

### 폐쇄몰별 상품 오버라이드 테이블

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

### 테이블 필드 설명

| 필드명 | 타입 | NULL | 기본값 | 설명 |
|--------|------|------|--------|------|
| cmio_id | INT(11) | NO | AUTO_INCREMENT | 오버라이드 ID (PK) |
| cm_id | INT(11) | NO | - | 폐쇄몰 ID |
| it_id | VARCHAR(20) | NO | - | 상품 ID |
| cmio_price | INT(11) | YES | NULL | 폐쇄몰 전용 가격 |
| cmio_price2 | INT(11) | YES | NULL | 폐쇄몰 전용 마진가 |
| cmio_cust_price | INT(11) | YES | NULL | 폐쇄몰 전용 정가 |
| cmio_sc_type | TINYINT(4) | YES | NULL | 배송비 타입 |
| cmio_sc_method | TINYINT(4) | YES | NULL | 배송비 부과 방식 |
| cmio_sc_price | INT(11) | YES | NULL | 기본 배송비 |
| cmio_sc_minimum | INT(11) | YES | NULL | 무료배송 최소금액 |
| cmio_discount_rate | DECIMAL(5,2) | YES | NULL | 폐쇄몰 전용 할인률 |
| cmio_stock_qty | INT(11) | YES | NULL | 폐쇄몰 전용 재고 |
| cmio_use | ENUM('Y','N') | NO | 'Y' | 사용 여부 |
| cmio_reg_time | DATETIME | NO | CURRENT_TIMESTAMP | 등록일시 |
| cmio_update_time | DATETIME | YES | NULL | 수정일시 |

### 인덱스 설명

| 인덱스명 | 타입 | 컬럼 | 설명 |
|----------|------|------|------|
| PRIMARY | PRIMARY | cmio_id | 기본 키 |
| uk_cm_item | UNIQUE | cm_id, it_id | 폐쇄몰+상품 조합 유일성 |
| idx_cm_id | INDEX | cm_id | 폐쇄몰별 조회 최적화 |
| idx_it_id | INDEX | it_id | 상품별 조회 최적화 |
| idx_use | INDEX | cmio_use | 사용 여부 필터링 |

---

## 구현 우선순위

### 🥇 1순위: Phase 1 (카테고리 독립화)

**이유**:
- ✅ 즉시 효과
- ✅ 변경 범위 작음
- ✅ 리스크 낮음

**효과**:
- 일반몰/폐쇄몰 명확히 구분
- 관리자 페이지에서 필터링 가능
- 카테고리 혼재 문제 해결

**일정**: 3일

---

### 🥈 2순위: Phase 3 (가격 테이블)

**이유**:
- ✅ Phase 2 없이도 구현 가능
- ✅ 장기적으로 최적
- ✅ 확장성 우수

**효과**:
- 상품 중복 없이 폐쇄몰별 가격 독립
- 재고는 원본과 공유 가능
- 배송비 정책 독립

**일정**: 7일

---

### 🥉 3순위: Phase 2 (상품 복사)

**이유**:
- ⚠️ Phase 3가 있으면 필요성 감소
- ⚠️ 상품 데이터 중복 발생

**효과**:
- 완전 독립이 필요한 경우에만 사용
- 특수한 케이스에 대응

**일정**: 2일 (선택사항)

---

## 총 예상 일정

### 최소 구성 (Phase 1 + Phase 3)
```
Phase 1: 3일
Phase 3: 7일
─────────────
총: 10일 (2주)
```

### 전체 구성 (Phase 1 + Phase 2 + Phase 3)
```
Phase 1: 3일
Phase 2: 2일
Phase 3: 7일
─────────────
총: 12일 (2.5주)
```

---

## 결론

### 최종 권장 사항

1. **Phase 1 먼저 구현** → 즉시 효과, 리스크 낮음
2. **Phase 3 구현** → 장기적 최적 구조
3. **Phase 2는 필요 시에만** → 선택사항

### 기대 효과

- ✅ 일반몰과 폐쇄몰의 완전한 독립 운영
- ✅ 폐쇄몰별 유연한 가격/배송비 정책
- ✅ 상품 데이터 중복 최소화
- ✅ 확장성 및 유지보수성 향상

---

## 참고 자료

### 관련 파일
- `adm/shop_admin/closedmallform.php` - 폐쇄몰 설정 폼
- `shop/closedmall_list.php` - 폐쇄몰 상품 목록
- `shop/closedmall_item.php` - 폐쇄몰 상품 상세
- `lib/closed_mall.lib.php` - 폐쇄몰 공통 함수

### 데이터베이스 테이블
- `gom_mall_closed_malls` - 폐쇄몰 관리
- `g5_shop_category` - 카테고리
- `g5_shop_item` - 상품
- `gom_mall_closed_mall_item_override` - 폐쇄몰별 상품 오버라이드 (신규)

---

**문서 버전**: 1.0  
**최종 수정일**: 2025-12-31  
**작성자**: AI Assistant
