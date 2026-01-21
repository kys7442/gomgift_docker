# 폐쇄몰 가격 표시 방식 통합 분석

## 목차
1. [개요](#개요)
2. [가격 표시 타입 (cm_price_display_type)](#가격-표시-타입)
3. [핵심 파일 및 함수](#핵심-파일-및-함수)
4. [가격 계산 흐름](#가격-계산-흐름)
5. [옵션 선택 시 가격 처리](#옵션-선택-시-가격-처리)
6. [장바구니 담기 처리](#장바구니-담기-처리)
7. [주문서 작성 및 주문 완료](#주문서-작성-및-주문-완료)
8. [데이터베이스 저장 구조](#데이터베이스-저장-구조)
9. [최근 수정 사항 (2026-01-08)](#최근-수정-사항)

---

## 개요

폐쇄몰은 **3가지 가격 표시 타입**을 지원하며, 각 타입에 따라 가격 계산 방식이 다릅니다.

### 폐쇄몰 설정 테이블 (gom_mall_closed_mall)
```sql
cm_price_display_type   VARCHAR(20)   -- 가격 표시 타입 ('purchase', 'margin', 'aov')
cm_discount_rate        DECIMAL(5,2)  -- 할인/할증률 (%)
cm_price_round_unit     INT(11)       -- 원단위 올림 (10, 100, 1000)
```

### 상품 테이블 관련 필드 (gom_mall_item)
```sql
it_price            INT(11)       -- 매입가
it_price2           INT(11)       -- 마진율 적용가 (일반 판매가)
it_aov_use          CHAR(1)       -- 객단가 사용 여부 ('Y'/'N')
it_aov_max_price    INT(11)       -- 객단가 최대가 (시중가로 사용)
```

---

## 가격 표시 타입

### 1. 매입가 기준 (purchase)

**계산 방식:**
- **판매가** = 매입가(it_price) × (1 + 할인률/100)
  - 할인률이 양수면 할증, 음수면 할인
- **시중가(취소선)** = 마진율 적용가(it_price2)
- **할인받은 금액** = 시중가 - 판매가

**예시:**
```
매입가(it_price) = 1,000원
할인률 = 10%
→ 판매가 = 1,000 × (1 + 10/100) = 1,100원

마진율 적용가(it_price2) = 1,500원
→ 시중가(취소선) = 1,500원
→ 할인받은 금액 = 1,500 - 1,100 = 400원
```

### 2. 마진율 기준 (margin)

**계산 방식:**
- **시중가(취소선)** = 마진율 적용가(it_price2)
- **판매가** = 마진율 금액(it_price2) × (1 - 할인률/100)
- **할인받은 금액** = 시중가 - 판매가

**예시:**
```
마진율 적용가(it_price2) = 1,500원
할인률 = 10%
→ 판매가 = 1,500 × (1 - 10/100) = 1,350원
→ 시중가(취소선) = 1,500원
→ 할인받은 금액 = 1,500 - 1,350 = 150원
```

### 3. 객단가 기준 (aov)

**계산 방식:**
- **판매가** = 수량별 객단가 × (1 - 할인률/100)
- **시중가(취소선)** = **it_aov_max_price** (객단가 최대가) 🔥
  - it_aov_max_price가 없으면 수량별 객단가를 폴백으로 사용
- **할인받은 금액** = 시중가 - 판매가 (수량별로 다름)

**예시:**
```
수량 1개: 객단가 = 1,000원, 할인률 10% → 판매가 = 900원
수량 10개: 객단가 = 800원, 할인률 10% → 판매가 = 720원
수량 50개: 객단가 = 600원, 할인률 10% → 판매가 = 540원

it_aov_max_price = 1,200원
→ 시중가(취소선) = 1,200원 (모든 수량 구간에서 동일)
→ 할인받은 금액 = 1,200 - 판매가 (수량별로 다름)
```

---

## 핵심 파일 및 함수

### PHP 파일

#### 1. 가격 계산 서비스
**파일:** `/lib/closed_mall_price_service.php`
- **클래스:** `ClosedMallPriceService`
- **주요 메서드:**
  - `applyDiscount($price, $rate)` - 할인 적용
  - `applySurcharge($price, $rate)` - 할증 적용
  - `getQtyColumnIndex($qty_row, $qty)` - 수량 구간 찾기 (AOV)
  - `calculateAovUnitPrice($it_id, $selected_option, $row_type, $qty, $aov_data)` - AOV 단가 계산
  - `loadAovData($it_id)` - AOV 데이터 로드
  - `getUnitPrice($item, $selected_option, $row_type, $qty, $price_display_type, $discount_rate, $aov_data, $price_round_unit)` - 통합 단가 계산

#### 2. 가격 표시 라이브러리
**파일:** `/lib/closed_mall_price_display.lib.php`
- **함수:**
  - `get_closed_mall_price_display($item, $cm, $is_member, $qty, $selected_option)` - 가격 계산 및 표시 정보 생성
  - `format_closed_mall_price_display($price_info, $options)` - HTML 생성

#### 3. 통합 가격 계산 🔥
**파일:** `/lib/closed_mall_price_unified.php`
- **함수:**
  - `get_closed_mall_price_unified($item, $cm, $qty, $selected_option, $is_member)` - 통합 가격 계산
    - **AOV 상품 (it_aov_use='Y' && cm_price_display_type='aov'):**
      - `ClosedMallPriceService::getUnitPrice()` 호출
      - 시중가(취소선) = **it_aov_max_price** (없으면 수량별 객단가)
      - 판매가 = 수량별 객단가 × (1 - 할인률/100)
    - **일반 상품:**
      - `get_closed_mall_price_display()` 호출
  - `format_closed_mall_price_display_unified($price_info, $options)` - 통합 HTML 생성

#### 4. 폐쇄몰 공통 라이브러리
**파일:** `/lib/closed_mall.lib.php`
- **함수:**
  - `get_closed_mall($cm_id)` - 폐쇄몰 정보 조회
  - `get_closed_mall_it_stock_qty($it_id)` - 상품 재고 조회
  - `get_closed_mall_option_stock_qty($it_id, $io_id, $io_type)` - 옵션 재고 조회
  - `get_closed_mall_sendcost($tmp_cart_id, $cm_id)` - 배송비 계산
  - `closed_mall_round_amount($amount, $round_unit)` - 원단위 올림

### JavaScript 파일

#### 1. 폐쇄몰 쇼핑 스크립트
**파일:** `/js/shop.closed.js`
- **주요 함수:**
  - `closedmall_price_calculate()` - 가격 계산 (클라이언트)
  - `closedmall_option_change()` - 옵션 변경 시 가격 업데이트
  - `closedmall_cart_submit()` - 장바구니 담기

#### 2. 폐쇄몰 상품 상세 스크립트
**파일:** `/js/closedmall_item.js`
- **클래스:** `ClosedMallItemManager`
- **주요 메서드:**
  - `init()` - 초기화
  - `loadConfig()` - 폐쇄몰 설정 로드
  - `calculatePrice()` - 가격 계산
  - `updateTotalPrice()` - 총 가격 업데이트

---

## 가격 계산 흐름

### 1. 상품 상세 페이지 (closedmall_item.php)

#### 1.1 페이지 로드 시
```php
// 1. 폐쇄몰 설정 로드
$cm = get_closed_mall($cm_id);
$cm_price_display_type = $cm['cm_price_display_type']; // 'purchase', 'margin', 'aov'
$cm_discount_rate = $cm['cm_discount_rate'];
$cm_price_round_unit = $cm['cm_price_round_unit'];

// 2. 상품 정보 로드
$it = get_shop_item_with_category($it_id);

// 3. 가격 계산 (통합 함수 사용)
include_once(G5_LIB_PATH.'/closed_mall_price_unified.php');
$price_info = get_closed_mall_price_unified($it, $cm, 1, '', $is_member);

// 4. 전역 변수 설정 (JavaScript에서 사용)
$GLOBALS['closed_mall_price_display_type'] = $cm_price_display_type;
$GLOBALS['closed_mall_discount_rate'] = $cm_discount_rate;
$GLOBALS['closed_mall_price_round_unit'] = $cm_price_round_unit;
```

#### 1.2 JavaScript로 설정 전달
```javascript
// closedmall_item.php (451-485줄)
var closed_mall_config = {
    cm_id: <?php echo (int)$cm_id; ?>,
    cm_price_display_type: <?php echo json_encode($cm_price_display_type); ?>,
    cm_discount_rate: <?php echo floatval($cm_discount_rate); ?>,
    cm_price_round_unit: <?php echo intval($cm_price_round_unit); ?>
};
window.closed_mall_config = closed_mall_config;
```

#### 1.3 옵션 데이터 캐시
```javascript
// closedmall_item.php (372-449줄)
var item_options_cache = {
    it_id: '<?php echo $it['it_id']; ?>',
    aov: [...],          // AOV 데이터
    options: [...],      // 선택옵션 데이터
    supply: [...],       // 추가옵션 데이터
    closed_mall: {
        cm_id: <?php echo $cm_id; ?>,
        cm_price_display_type: '<?php echo $cm_price_display_type; ?>',
        cm_discount_rate: <?php echo $cm_discount_rate; ?>,
        cm_price_round_unit: <?php echo $cm_price_round_unit; ?>
    }
};
window.itemOptionsCache = item_options_cache;
```

---

## 옵션 선택 시 가격 처리

### 2. 옵션 선택 (JavaScript)

#### 2.1 AOV 옵션 선택 시
```javascript
// closedmall_item.js
calculatePrice: function() {
    var config = this.config;
    var price_display_type = config.price_display_type;
    var discount_rate = config.discount_rate;
    var price_round_unit = config.price_round_unit;
    
    // AOV 상품인 경우
    if (price_display_type === 'aov') {
        // 서버에 AJAX 요청하여 수량별 가격 계산
        $.ajax({
            url: '/shop/ajax_closedmall_aov_data.php',
            data: {
                it_id: config.it_id,
                cm_id: config.cm_id,
                qty: qty,
                selected_option: selected_option
            },
            success: function(response) {
                // 서버에서 계산된 가격 사용
                var unit_price = response.unit_price;
                updateTotalPrice(unit_price * qty);
            }
        });
    }
}
```

#### 2.2 일반 옵션 선택 시 (purchase/margin)
```javascript
// shop.closed.js (537-595줄)
function closedmall_price_calculate() {
    var cm_price_display_type = $("#cm_price_display_type").val() || 'purchase';
    var cm_discount_rate = parseFloat($("#cm_discount_rate").val()) || 0;
    var cm_price_round_unit = parseInt($("#cm_price_round_unit").val()) || 0;
    
    // 원본 가격 가져오기
    var original_price = 0;
    if (cm_price_display_type === 'purchase' || cm_price_display_type === 'aov') {
        original_price = parseInt($("input#it_price").val()) || 0;
    } else if (cm_price_display_type === 'margin') {
        original_price = parseInt($("input#it_price2").val()) || 0;
    }
    
    // 할인/할증 적용
    var display_price = original_price;
    if (cm_price_display_type === 'purchase' && cm_discount_rate != 0) {
        if (cm_discount_rate > 0) {
            // 할증
            display_price = original_price * (1 + (cm_discount_rate / 100));
        } else {
            // 할인
            display_price = original_price * (1 - (Math.abs(cm_discount_rate) / 100));
        }
    } else if (cm_price_display_type === 'margin' && cm_discount_rate > 0) {
        // 할인
        display_price = original_price * (1 - (cm_discount_rate / 100));
    }
    
    // 원단위 올림
    if (cm_price_round_unit > 0 && [10, 100, 1000].indexOf(cm_price_round_unit) !== -1) {
        display_price = Math.ceil(display_price / cm_price_round_unit) * cm_price_round_unit;
    }
    
    return display_price;
}
```

---

## 장바구니 담기 처리

### 3. 장바구니 업데이트 (closedmall_cartupdate.php)

#### 3.1 폐쇄몰 설정 로드
```php
// closedmall_cartupdate.php (42-44줄)
$cm_price_display_type = isset($cm['cm_price_display_type']) ? $cm['cm_price_display_type'] : 'purchase';
$cm_discount_rate = isset($cm['cm_discount_rate']) ? floatval($cm['cm_discount_rate']) : 0;
$cm_price_round_unit = isset($cm['cm_price_round_unit']) ? intval($cm['cm_price_round_unit']) : 0;
```

#### 3.2 가격 계산 (통합 함수 사용) 🔥
```php
// closedmall_cartupdate.php (764-786줄)
include_once(G5_LIB_PATH.'/closed_mall_price_unified.php');

// AOV 상품인 경우 필수옵션 추출
$selected_option = '';
if($it['it_aov_use'] == 'Y') {
    $aov_option_name = $_POST['io_closed_value'][$it_id][$k];
    if (strpos($aov_option_name, '필수옵션:') === 0) {
        $after_prefix = trim(substr($aov_option_name, strlen('필수옵션:')));
        $slash_pos = strpos($after_prefix, ' / ');
        if ($slash_pos !== false) {
            $selected_option = trim(substr($after_prefix, 0, $slash_pos));
        } else {
            $selected_option = $after_prefix;
        }
    }
}

// 🔥 통합 가격 계산 함수 사용 (AOV 상품도 자동 처리)
// - AOV 상품: it_aov_max_price를 시중가(취소선)로 사용
// - 일반 상품: it_price2를 시중가(취소선)로 사용
$price_info = get_closed_mall_price_unified($it, $cm, max(1, $ct_qty), $selected_option, $is_member);
$closed_base_unit_price = $price_info['display_price'];
$it_aov_price = isset($price_info['unit_price']) ? $price_info['unit_price'] : 0;
```

#### 3.3 장바구니 테이블 저장
```php
// closedmall_cartupdate.php (689-962줄)
$sql = " INSERT INTO {$g5['g5_shop_cart_table']}
        ( od_id, mb_id, it_id, it_name, ..., ct_price, ..., io_price, it_aov_price, ..., ct_closed_mall_id, ct_supply_price )
    VALUES ";

for($k=0; $k<$opt_count; $k++) {
    // AOV 옵션 처리
    if($io_type == '0' && strpos($io_value, '필수옵션:') === 0) {
        $io_price = 0;
        if(isset($_POST['aov_closed_option_extra'][$it_id][$k])) {
            $io_price = (int)$_POST['aov_closed_option_extra'][$it_id][$k];
        }
    } else {
        // 일반 옵션 가격에도 폐쇄몰 할인률 적용
        if($io_price > 0 && $cm_discount_rate != 0) {
            if($cm_price_display_type === 'purchase') {
                if($cm_discount_rate > 0) {
                    $io_price = $io_price * (1 + ($cm_discount_rate / 100));
                } else {
                    $io_price = $io_price * (1 - (abs($cm_discount_rate) / 100));
                }
            } elseif($cm_price_display_type === 'margin' && $cm_discount_rate > 0) {
                $io_price = $io_price * (1 - ($cm_discount_rate / 100));
            }
            
            // 원단위 올림 처리
            if($cm_price_round_unit > 0) {
                $io_price = intval(ceil($io_price / $cm_price_round_unit) * $cm_price_round_unit);
            }
        }
    }
    
    // ct_price: 판매가 (display_price)
    $ct_price_for_insert = (int)$closed_base_unit_price;
    
    // ct_supply_price: 매입가 (it_price)
    $supply_price_value = ", '".(int)$it['it_price']."'";
    
    $insert_values = "( '$tmp_cart_id', '{$member['mb_id']}', '{$it['it_id']}', ..., 
                        '{$ct_price_for_insert}', ..., '$io_price', '$it_aov_price', ..., 
                        '$cm_id'{$supply_price_value} )";
    $sql .= $comma . $insert_values;
    $comma = ' , ';
}

sql_query($sql);
```

#### 3.4 장바구니 테이블 구조
```sql
-- gom_mall_cart
ct_id               INT(11)       -- 장바구니 ID (PK)
od_id               VARCHAR(20)   -- 주문 ID (세션 cart_id)
it_id               VARCHAR(20)   -- 상품 ID
ct_price            INT(11)       -- 판매가 (display_price)
ct_qty              INT(11)       -- 수량
io_id               VARCHAR(255)  -- 옵션 ID
io_type             TINYINT(4)    -- 옵션 타입 (0: 선택옵션, 1: 추가옵션)
io_price            INT(11)       -- 옵션 가격 (할인/할증 적용)
it_aov_price        INT(11)       -- AOV 단가 (AOV 상품인 경우)
ct_option           TEXT          -- 옵션명 (예: "필수옵션:기본가")
ct_closed_mall_id   INT(11)       -- 폐쇄몰 ID
ct_supply_price     INT(11)       -- 매입가 (it_price)
ct_select           TINYINT(1)    -- 선택 여부 (1: 선택, 0: 미선택)
ct_status           VARCHAR(10)   -- 상태 ('쇼핑', '주문', '배송중' 등)
```

---

## 주문서 작성 및 주문 완료

### 4. 주문서 작성 (closedmall_orderform.php)

#### 4.1 장바구니 조회
```php
// closedmall_orderform.php (48-60줄)
$sql = " select count(*) as cnt from {$g5['g5_shop_cart_table']} 
         where od_id = '$tmp_cart_id' 
           and ct_closed_mall_id = '{$cm_id}'
           and ct_status = '쇼핑' ";
$row = sql_fetch($sql);
if ($row['cnt'] == 0) {
    alert('장바구니가 비어 있습니다.', G5_SHOP_URL.'/closedmall_cart.php?cm_id='.$cm_id);
}
```

#### 4.2 선택된 상품 확인
```php
// closedmall_orderform.php (64-78줄)
$sql = " select count(*) as cnt from {$g5['g5_shop_cart_table']} 
         where od_id = '$tmp_cart_id' 
           and ct_select = '1' 
           and ct_closed_mall_id = '{$cm_id}'
           and ct_status = '쇼핑' ";
$row = sql_fetch($sql);
if ($row['cnt'] == 0) {
    alert('주문하실 상품을 선택해 주세요.', G5_SHOP_URL.'/closedmall_cart.php?cm_id='.$cm_id);
}
```

### 5. 주문 처리 (closedmall_orderformupdate.php)

#### 5.1 주문 금액 계산
```php
// closedmall_orderformupdate.php (253-338줄)
$tot_ct_price = 0;
$cart_count = 0;

$calc_sql = " select a.it_id, a.ct_price, a.it_aov_price, a.io_type, a.io_price, a.ct_qty
                from {$g5['g5_shop_cart_table']} a
               where a.od_id = '$tmp_cart_id_escaped'
                 and a.ct_select = '1'
                 and a.ct_closed_mall_id = '{$cm_id}'
                 and a.ct_status = '쇼핑' ";
$calc_res = sql_query($calc_sql);

while($crow = sql_fetch_array($calc_res)) {
    $qty = (int)$crow['ct_qty'];
    $io_type = (int)$crow['io_type'];
    $io_price = (int)$crow['io_price'];
    $ct_price = (int)$crow['ct_price'];
    $it_aov_price = (int)$crow['it_aov_price'];
    
    $line_total = 0;
    if($io_type === 1) {
        // 추가 옵션: 옵션가 * 수량
        $line_total = $io_price * $qty;
    } else {
        // 선택 옵션: (기본가 + 옵션가) * 수량
        $base = ($it_aov_price > 0) ? $it_aov_price : $ct_price;
        $line_total = ($base + $io_price) * $qty;
    }
    
    // 원단위 올림 처리
    $tot_ct_price += closed_mall_round_amount($line_total, $cm_price_round_unit);
}
```

#### 5.2 주문 테이블 저장
```php
// closedmall_orderformupdate.php (주문 완료 후)
// 주문 테이블 (gom_mall_order)
$sql = " INSERT INTO {$g5['g5_shop_order_table']} SET
         od_id = '$od_id',
         mb_id = '{$member['mb_id']}',
         od_name = '$od_name',
         od_price = '$tot_ct_price',
         od_send_cost = '$send_cost',
         od_receipt_price = '$od_receipt_price',
         od_closed_mall_id = '$cm_id',
         ... ";
sql_query($sql);

// 장바구니 → 주문 상세 테이블로 이동 (gom_mall_cart → gom_mall_cart)
$sql = " UPDATE {$g5['g5_shop_cart_table']} SET
         od_id = '$od_id',
         ct_status = '주문'
         WHERE od_id = '$tmp_cart_id'
           AND ct_select = '1'
           AND ct_closed_mall_id = '{$cm_id}' ";
sql_query($sql);
```

#### 5.3 주문 테이블 구조
```sql
-- gom_mall_order
od_id               VARCHAR(20)   -- 주문 ID (PK)
mb_id               VARCHAR(20)   -- 회원 ID
od_name             VARCHAR(20)   -- 주문자명
od_price            INT(11)       -- 주문 상품 금액 (쿠폰 적용 후)
od_send_cost        INT(11)       -- 배송비
od_receipt_price    INT(11)       -- 결제 금액
od_closed_mall_id   INT(11)       -- 폐쇄몰 ID
od_settle_case      VARCHAR(20)   -- 결제 방법
od_status           VARCHAR(20)   -- 주문 상태
...
```

---

## 데이터베이스 저장 구조

### 장바구니 테이블 (gom_mall_cart)

| 컬럼명 | 타입 | 설명 | 값 예시 |
|--------|------|------|---------|
| ct_id | INT(11) | 장바구니 ID (PK) | 1234 |
| od_id | VARCHAR(20) | 주문 ID (세션 cart_id) | "abc123xyz" |
| it_id | VARCHAR(20) | 상품 ID | "1759283374" |
| ct_price | INT(11) | **판매가** (display_price) | 1100 (purchase), 1350 (margin), 900 (aov) |
| ct_qty | INT(11) | 수량 | 10 |
| io_id | VARCHAR(255) | 옵션 ID | "기본가" (AOV), "색상-빨강" (일반) |
| io_type | TINYINT(4) | 옵션 타입 | 0 (선택옵션), 1 (추가옵션) |
| io_price | INT(11) | 옵션 가격 (할인/할증 적용) | 100 |
| it_aov_price | INT(11) | **AOV 단가** (AOV 상품인 경우) | 900 (수량별 단가) |
| ct_option | TEXT | 옵션명 | "필수옵션:기본가" (AOV), "색상-빨강" (일반) |
| ct_closed_mall_id | INT(11) | 폐쇄몰 ID | 1765951232 |
| ct_supply_price | INT(11) | **매입가** (it_price) | 1000 |
| ct_select | TINYINT(1) | 선택 여부 | 1 (선택), 0 (미선택) |
| ct_status | VARCHAR(10) | 상태 | '쇼핑', '주문', '배송중' |

### 가격 필드 설명

#### 1. ct_price (판매가)
- **purchase 타입:** `it_price × (1 + 할인률/100)` + 원단위 올림
- **margin 타입:** `it_price2 × (1 - 할인률/100)` + 원단위 올림
- **aov 타입:** `수량별 객단가 × (1 - 할인률/100)` + 원단위 올림

#### 2. it_aov_price (AOV 단가)
- **AOV 상품인 경우에만 사용**
- 수량 구간별로 다른 단가 적용
- `ClosedMallPriceService::getUnitPrice()` 함수로 계산

#### 3. ct_supply_price (매입가)
- **주문 당시의 it_price 값 저장**
- 가격 변동 추적 및 마진 계산에 사용

#### 4. io_price (옵션 가격)
- **선택옵션/추가옵션 가격**
- 폐쇄몰 할인률 적용됨
- 원단위 올림 처리됨

### 주문 테이블 (gom_mall_order)

| 컬럼명 | 타입 | 설명 | 값 예시 |
|--------|------|------|---------|
| od_id | VARCHAR(20) | 주문 ID (PK) | "20260108123456" |
| mb_id | VARCHAR(20) | 회원 ID | "user123" |
| od_price | INT(11) | 주문 상품 금액 (쿠폰 적용 후) | 10000 |
| od_send_cost | INT(11) | 배송비 | 3000 |
| od_receipt_price | INT(11) | 결제 금액 | 13000 |
| od_closed_mall_id | INT(11) | 폐쇄몰 ID | 1765951232 |
| od_settle_case | VARCHAR(20) | 결제 방법 | "신용카드", "무통장" |
| od_status | VARCHAR(20) | 주문 상태 | "주문", "입금", "배송중" |

---

## 가격 계산 흐름 요약

### 전체 흐름도

```
[상품 상세 페이지]
    ↓
1. 폐쇄몰 설정 로드 (cm_price_display_type, cm_discount_rate, cm_price_round_unit)
    ↓
2. 상품 정보 로드 (it_price, it_price2, it_aov_use, it_aov_max_price)
    ↓
3. 가격 계산 (get_closed_mall_price_unified)
    ├─ purchase: it_price × (1 + 할인률/100)
    ├─ margin: it_price2 × (1 - 할인률/100)
    └─ aov: 수량별 객단가 × (1 - 할인률/100)
         시중가(취소선) = it_aov_max_price 🔥
    ↓
4. 원단위 올림 (cm_price_round_unit)
    ↓
5. JavaScript로 설정 전달 (closed_mall_config, itemOptionsCache)
    ↓
[옵션 선택]
    ↓
6. JavaScript에서 가격 계산 (closedmall_price_calculate)
    ├─ AOV: AJAX로 서버에 요청 (ajax_closedmall_aov_data.php)
    └─ 일반: 클라이언트에서 계산
    ↓
7. 총 가격 업데이트 (updateTotalPrice)
    ↓
[장바구니 담기]
    ↓
8. 장바구니 업데이트 (closedmall_cartupdate.php)
    ↓
9. 가격 재계산 (get_closed_mall_price_unified) 🔥
    ↓
10. 장바구니 테이블 저장
    ├─ ct_price: 판매가 (display_price)
    ├─ it_aov_price: AOV 단가 (AOV 상품인 경우)
    ├─ ct_supply_price: 매입가 (it_price)
    └─ io_price: 옵션 가격 (할인/할증 적용)
    ↓
[주문서 작성]
    ↓
11. 장바구니 조회 (ct_closed_mall_id, ct_select = '1')
    ↓
12. 주문 금액 계산
    ├─ 추가 옵션: io_price × qty
    └─ 선택 옵션: (ct_price + io_price) × qty
    ↓
13. 원단위 올림 (closed_mall_round_amount)
    ↓
[주문 완료]
    ↓
14. 주문 테이블 저장 (gom_mall_order)
    ↓
15. 장바구니 상태 업데이트 (ct_status = '주문')
```

---

## 최근 수정 사항

### 2026-01-08: 객단가(AOV) 상품 가격 표시 개선 🔥

#### 수정 내용

**1. 시중가(취소선) 표시 방식 변경**
- **이전:** AOV 상품의 시중가(취소선)를 `it_price2` (마진율 적용가)로 표시
- **변경:** AOV 상품의 시중가(취소선)를 `it_aov_max_price` (객단가 최대가)로 표시
  - `it_aov_max_price`가 없는 경우 수량별 객단가를 폴백으로 사용

**2. 할인 금액 계산 방식 변경**
- **이전:** 할인 금액 = `it_price2` - 판매가
- **변경:** 할인 금액 = `it_aov_max_price` - 판매가

#### 수정된 파일

1. **`/lib/closed_mall_price_unified.php`** (Line 38-73)
   - AOV 상품의 `cancel_price` 계산 로직 수정
   - `it_aov_max_price` 우선 사용, 없으면 폴백

2. **`/lib/closed_mall_price_display.lib.php`** (Line 195-220, 237-262)
   - 수량/옵션이 있는 경우와 없는 경우 모두 `it_aov_max_price` 사용
   - 할인 금액 재계산 로직 추가

#### 영향 범위

- **상품 리스트 페이지** (`closedmall_list.php`): 자동 적용 ✅
- **상품 상세 페이지** (`closedmall_item.php`): 자동 적용 ✅
- **장바구니 담기** (`closedmall_cartupdate.php`): 자동 적용 ✅
  - `get_closed_mall_price_unified()` 함수를 사용하므로 수정 내용이 자동으로 반영됨
- **주문서 작성** (`closedmall_orderform.php`): 자동 적용 ✅
- **주문 처리** (`closedmall_orderformupdate.php`): 자동 적용 ✅

#### 예시

**수정 전:**
```
AOV 상품 (수량 10개)
- 객단가: 800원
- 할인률: 10%
- it_price2: 1,500원
- it_aov_max_price: 1,200원

→ 판매가: 720원 (800 × 0.9)
→ 시중가(취소선): 1,500원 (it_price2)
→ 할인 금액: 780원 (1,500 - 720)
```

**수정 후:**
```
AOV 상품 (수량 10개)
- 객단가: 800원
- 할인률: 10%
- it_price2: 1,500원
- it_aov_max_price: 1,200원

→ 판매가: 720원 (800 × 0.9)
→ 시중가(취소선): 1,200원 (it_aov_max_price) 🔥
→ 할인 금액: 480원 (1,200 - 720) 🔥
```

---

## 핵심 포인트

### 1. 가격 계산 일관성
- **모든 단계에서 동일한 함수 사용:** `get_closed_mall_price_unified()`
- **원단위 올림 일관성:** `closed_mall_round_amount()` 함수 사용
- **할인/할증 적용 일관성:** `ClosedMallPriceService` 클래스 사용

### 2. 데이터 저장 구조
- **ct_price:** 판매가 (display_price) - 고객이 실제 지불하는 가격
- **it_aov_price:** AOV 단가 (AOV 상품인 경우) - 수량별 단가
- **ct_supply_price:** 매입가 (it_price) - 주문 당시 매입가 (마진 계산용)
- **io_price:** 옵션 가격 (할인/할증 적용) - 추가 옵션 가격

### 3. 가격 표시 타입별 차이점

| 타입 | 판매가 기준 | 시중가(취소선) | 할인 금액 계산 |
|------|-------------|----------------|----------------|
| purchase | it_price + 할인률 | it_price2 | 시중가 - 판매가 |
| margin | it_price2 - 할인률 | it_price2 | 시중가 - 판매가 |
| aov | 수량별 객단가 - 할인률 | **it_aov_max_price** 🔥 | 시중가 - 판매가 |

### 4. 주요 검증 포인트
- **재고 체크:** `get_closed_mall_it_stock_qty()`, `get_closed_mall_option_stock_qty()`
- **가격 검증:** 클라이언트와 서버 계산 결과 일치 확인
- **폐쇄몰 ID 필터링:** 모든 쿼리에 `ct_closed_mall_id` 조건 추가
- **선택 상품 필터링:** `ct_select = '1'` 조건으로 선택된 상품만 처리

---

## 관련 파일 목록

### PHP 파일
- `/lib/closed_mall_price_service.php` - 가격 계산 서비스
- `/lib/closed_mall_price_display.lib.php` - 가격 표시 라이브러리
- `/lib/closed_mall_price_unified.php` - 통합 가격 계산 🔥
- `/lib/closed_mall.lib.php` - 폐쇄몰 공통 라이브러리
- `/shop/closedmall_item.php` - 상품 상세 페이지
- `/shop/closedmall_cartupdate.php` - 장바구니 업데이트
- `/shop/closedmall_orderform.php` - 주문서 작성
- `/shop/closedmall_orderformupdate.php` - 주문 처리
- `/shop/ajax_closedmall_aov_data.php` - AOV 데이터 AJAX
- `/shop/ajax_closedmall_price.php` - 가격 계산 AJAX

### JavaScript 파일
- `/js/shop.closed.js` - 폐쇄몰 쇼핑 스크립트
- `/js/closedmall_item.js` - 폐쇄몰 상품 상세 스크립트
- `/js/closedmall_shop.order.js` - 폐쇄몰 주문 스크립트

---

## 결론

폐쇄몰의 가격 표시 방식은 **3가지 타입(purchase, margin, aov)**을 지원하며, 각 타입에 따라 가격 계산 방식이 다릅니다. 

**핵심 특징:**
1. **통합 가격 계산 함수** 사용으로 일관성 유지
2. **원단위 올림 처리** 일관성 유지
3. **폐쇄몰 ID 필터링**으로 일반몰과 분리
4. **장바구니 테이블**에 판매가, AOV 단가, 매입가 모두 저장
5. **옵션 선택 시** 클라이언트와 서버 모두에서 가격 계산
6. **주문 완료 시** 장바구니 데이터를 주문 테이블로 이동
7. **AOV 상품의 시중가(취소선)** = `it_aov_max_price` (객단가 최대가) 🔥

이러한 구조를 통해 폐쇄몰은 다양한 가격 정책을 유연하게 지원하면서도 데이터 일관성을 유지합니다.
