# 폐쇄몰/복지몰 개발 로드맵

## 프로젝트 개요
특정 권한(레벨 권한 페이지 설정)이 있는 회원만 구매할 수 있는 폐쇄몰/복지몰 시스템 구축

## 핵심 요구사항
- ✅ 특정 권한 회원만 접근 가능
- ✅ UI는 기존과 동일, 가격 표시/결제금액만 차이
- ✅ `it_aov_use` 무시, `it_price`만 사용
- ✅ 선택옵션, 추가옵션은 영카트 기본 로직 사용
- ✅ 플로우: 상품목록 → 상품상세 → 장바구니/바로구매 → 주문정보 입력 → 결제 → 주문완료
- ✅ 관리자 페이지에서 폐쇄몰 설정 및 관리 가능

---

## Phase 0: 관리자 페이지 - 폐쇄몰 관리 시스템 구축 (최우선)

### 0.1 데이터베이스 테이블 생성
- [ ] `gom_mall_closed_malls` 테이블 생성
  - `cm_id`: 폐쇄몰 관리번호 (AUTO_INCREMENT, PRIMARY KEY)
  - `cm_title`: 폐쇄몰 제목 (VARCHAR)
  - `cm_use`: 사용 여부 (ENUM('Y','N'), DEFAULT 'N')
  - `cm_start_date`: 운영 시작일시 (DATETIME, NULL 가능)
  - `cm_end_date`: 운영 종료일시 (DATETIME, NULL 가능)
  - `cm_access_type`: 접근 권한 타입 (ENUM('member','level','code'), DEFAULT 'level')
  - `cm_access_members`: 접근 가능 회원 목록 (TEXT, JSON 형식)
  - `cm_access_levels`: 접근 가능 레벨 목록 (TEXT, JSON 형식)
  - `cm_access_code`: 입장 코드 (VARCHAR, NULL 가능)
  - `cm_product_type`: 진열 상품 타입 (ENUM('category','item','partner'), DEFAULT 'category')
  - `cm_product_categories`: 카테고리 목록 (TEXT, JSON 형식)
  - `cm_product_items`: 상품코드 목록 (TEXT, JSON 형식)
  - `cm_product_partners`: 파트너사 코드 목록 (TEXT, JSON 형식)
  - `cm_banner_image`: 타이틀 이미지/배너 (VARCHAR, 파일 경로)
  - `cm_skin`: 사용할 스킨 (VARCHAR, 기본값 'list.10.skin.php')
  - `cm_payment_methods`: 결제 수단 (TEXT, JSON 형식 - 무통장, 카드, 쿠폰, 포인트 등)
  - `cm_pagination_type`: 페이징 타입 (ENUM('more','paging'), DEFAULT 'paging')
  - `cm_reg_time`: 등록일시 (DATETIME)
  - `cm_update_time`: 수정일시 (DATETIME)
  - 인덱스: `cm_use`, `cm_start_date`, `cm_end_date`

### 0.2 관리자 메뉴 추가
- [ ] `adm/admin.menu500.shop_2of2.php` 수정
  - 이벤트관리(`500300`) 아래에 폐쇄몰(복지몰) 관리 메뉴 추가
  - 메뉴 코드: `500320`
  - 파일 경로: `adm/shop_admin/closedmalllist.php`

### 0.3 폐쇄몰 목록 페이지 생성
- [ ] `adm/shop_admin/closedmalllist.php` 생성
  - 폐쇄몰 목록 표시
  - 제목, 사용여부, 운영기간, 관리 버튼 표시
  - 이벤트 관리 페이지(`itemevent.php`) 참고

### 0.4 폐쇄몰 등록/수정 페이지 생성
- [ ] `adm/shop_admin/closedmallform.php` 생성
  - 폐쇄몰 등록/수정 폼
  - 모든 설정 항목 입력 가능
  - 이벤트 등록 페이지(`itemeventform.php`) 참고

### 0.5 폐쇄몰 설정 항목 구현
- [ ] 기본 정보 입력
  - 제목, 사용여부 체크박스
- [ ] 운영 기간 설정
  - 시작일시, 종료일시 (날짜/시간 선택)
  - 무제한 옵션
- [ ] 접근 권한 설정
  - 라디오 버튼: 회원 선택 / 레벨 선택 / 입장 코드
  - 회원 선택: 멀티 셀렉트 또는 검색 기능
  - 레벨 선택: 체크박스 형태
  - 입장 코드: 텍스트 입력
- [ ] 진열 상품 설정
  - 라디오 버튼: 카테고리 / 상품코드 / 파트너사
  - 카테고리: 멀티 셀렉트 (트리 구조)
  - 상품코드: 텍스트 영역 (엔터로 구분) 또는 검색 기능
  - 파트너사: 멀티 셀렉트 또는 검색 기능
- [ ] 타이틀 이미지 업로드
  - 파일 업로드 기능
  - 이미지 미리보기
- [ ] 스킨 선택
  - 드롭다운: `theme/kiwi/skin/shop/basic/` 내 스킨 파일 목록
  - 기본값: `list.10.skin.php`
- [ ] 결제 수단 선택
  - 체크박스: 무통장입금, 신용카드, 실시간계좌이체, 가상계좌, 휴대폰, 쿠폰, 포인트
- [ ] 페이징 타입 선택
  - 라디오 버튼: 더보기 / 페이징

### 0.6 폐쇄몰 저장/수정 처리
- [ ] `adm/shop_admin/closedmallformupdate.php` 생성
  - 폐쇄몰 데이터 저장/수정 처리
  - 파일 업로드 처리
  - JSON 데이터 직렬화 처리
  - 유효성 검증

### 0.7 폐쇄몰 삭제 기능
- [ ] `closedmalllist.php`에 삭제 기능 추가
  - 체크박스 선택 후 일괄 삭제
  - 개별 삭제

### 0.8 AJAX 유틸리티 (선택사항)
- [ ] 상품 검색 AJAX (`ajax_admin_closed_mall_product_search.php`)
- [ ] 회원 검색 AJAX (`ajax_admin_closed_mall_member_search.php`)
- [ ] 파트너사 검색 AJAX (`ajax_admin_closed_mall_partner_search.php`)

---

## Phase 1: 권한 시스템 및 설정 구성

### 1.1 권한 설정 테이블/설정 확인
- [ ] 레벨별 권한 테이블(`g5_auth_level`) 확인
- [ ] 폐쇄몰 접근 권한 메뉴 코드 정의 (예: `closed_mall_access`)
- [ ] 관리자 페이지에서 권한 설정 UI 확인

### 1.2 권한 체크 공통 함수 생성
- [ ] `lib/closed_mall.lib.php` 생성
  - `is_closed_mall_member()`: 폐쇄몰 접근 권한 체크 함수
  - 레벨별 권한 또는 회원별 권한 확인
  - 권한 없을 시 접근 차단 및 안내 페이지

### 1.3 환경 설정
- [ ] `.env` 또는 설정 파일에 폐쇄몰 관련 설정 추가
  - `CLOSED_MALL_ENABLED`: 폐쇄몰 활성화 여부
  - `CLOSED_MALL_AUTH_MENU`: 권한 메뉴 코드

---

## Phase 2: 상품 진열 페이지 (List)

### 2.1 파일 생성/수정
- [ ] `theme/kiwi/skin/shop/basic/list.closed.skin.php` 생성
  - 기존 `list.10.skin.php` 복사
  - 가격 표시 로직 수정: `it_price`만 사용, AOV 무시

### 2.2 가격 표시 로직 수정
- [ ] `it_aov_use` 체크 제거
- [ ] `it_price`만 표시
- [ ] 회원 등급별 할인 적용 (필요시)

### 2.3 권한 체크 추가
- [ ] 페이지 상단에 권한 체크
- [ ] 권한 없을 시 접근 차단 메시지

### 2.4 카테고리/검색 연동
- [ ] 기존 카테고리 시스템 활용
- [ ] 검색 기능 정상 작동 확인

---

## Phase 3: 상품 상세 페이지 (Detail)

### 3.1 파일 생성/수정
- [ ] `theme/kiwi/skin/shop/basic/item.form.closed.skin.php` 생성
  - 기존 `item.form.skin.php` 복사
  - 가격 표시 로직 수정

### 3.2 가격 표시 로직 수정
- [ ] `it_price`만 표시 (AOV 무시)
- [ ] 옵션 가격은 영카트 기본 로직 사용
  - 선택옵션: `io_price` 사용
  - 추가옵션: `io_price` 사용
- [ ] 최종 가격 계산: `it_price + 옵션가격`

### 3.3 옵션 처리
- [ ] AOV 관련 로직 제거
- [ ] 영카트 기본 옵션 처리 로직만 사용
- [ ] 옵션 선택 UI는 기존과 동일

### 3.4 장바구니/바로구매 버튼
- [ ] 기존 버튼 유지
- [ ] 권한 체크 후 장바구니 추가/바로구매 진행

### 3.5 권한 체크 추가
- [ ] 페이지 상단에 권한 체크
- [ ] 권한 없을 시 접근 차단

---

## Phase 4: 장바구니 페이지 (Cart)

### 4.1 파일 확인/수정
- [ ] `shop/cart.php` 확인
- [ ] 폐쇄몰 모드 감지 로직 추가
- [ ] 가격 계산 로직 수정

### 4.2 가격 계산 로직 수정
- [ ] `it_price`만 사용 (AOV 무시)
- [ ] 옵션 가격은 영카트 기본 로직
- [ ] 장바구니 총액 계산 수정

### 4.3 권한 체크
- [ ] 장바구니 접근 시 권한 체크
- [ ] 권한 없는 상품 자동 제거 (선택사항)

---

## Phase 5: 주문정보 입력 페이지 (Order Form)

### 5.1 파일 확인/수정
- [ ] `shop/orderform.php` 확인
- [ ] 폐쇄몰 모드 감지 로직 추가

### 5.2 가격 계산 로직 수정
- [ ] `orderformupdate.php` 또는 관련 파일 수정
- [ ] `it_price`만 사용 (AOV 무시)
- [ ] 옵션 가격은 영카트 기본 로직
- [ ] 배송비, 포인트 등 기타 계산은 기존 로직 유지

### 5.3 주문서 UI
- [ ] 기존 UI 유지
- [ ] 가격 표시만 수정

### 5.4 권한 체크
- [ ] 주문서 접근 시 권한 체크
- [ ] 권한 없을 시 장바구니로 리다이렉트

---

## Phase 6: 결제 진행 (Payment)

### 6.1 결제 프로세스 수정
- [ ] `shop/orderformupdate.php` 확인
- [ ] 가격 계산 로직 수정
- [ ] 결제 금액 = `it_price + 옵션가격 + 배송비 - 포인트 - 쿠폰`

### 6.2 결제 모듈 연동
- [ ] 기존 결제 모듈(이니시스, KCP 등) 그대로 사용
- [ ] 결제 금액만 수정된 값으로 전달

### 6.3 주문 데이터 저장
- [ ] `g5_shop_order_table` 저장 시 가격 정보 확인
- [ ] `g5_shop_cart_table` 저장 시 `it_aov_price` 무시

---

## Phase 7: 주문 완료 페이지 (Order Complete)

### 7.1 파일 확인/수정
- [ ] 주문 완료 페이지 확인 (보통 `shop/orderinquiryview.php` 또는 별도 파일)
- [ ] 가격 표시 로직 수정

### 7.2 주문 내역 표시
- [ ] `it_price`만 표시
- [ ] 옵션 가격 표시
- [ ] 총 결제 금액 표시

---

## Phase 8: 공통 수정 사항

### 8.1 장바구니 추가 로직
- [ ] `shop/cartupdate.php` 수정
  - AOV 관련 로직 제거
  - `it_price`만 사용
  - 옵션 가격은 영카트 기본 로직

### 8.2 AJAX 가격 계산
- [ ] 상품 상세 페이지의 실시간 가격 계산 수정
- [ ] AOV 관련 JavaScript 제거
- [ ] `it_price + 옵션가격` 계산 로직

### 8.3 주문 조회 페이지
- [ ] `shop/orderinquiry.php` 확인
- [ ] 가격 표시 로직 수정

---

## Phase 9: 테스트 및 검증

### 9.1 기능 테스트
- [ ] 권한 없는 회원 접근 차단 확인
- [ ] 권한 있는 회원 정상 접근 확인
- [ ] 상품 목록 가격 표시 확인
- [ ] 상품 상세 가격 표시 확인
- [ ] 옵션 선택 및 가격 계산 확인
- [ ] 장바구니 가격 계산 확인
- [ ] 주문서 가격 계산 확인
- [ ] 결제 금액 확인
- [ ] 주문 완료 후 내역 확인

### 9.2 통합 테스트
- [ ] 전체 플로우 테스트
- [ ] 다양한 옵션 조합 테스트
- [ ] 에러 케이스 테스트

### 9.3 성능 테스트
- [ ] 페이지 로딩 속도 확인
- [ ] 데이터베이스 쿼리 최적화

---

## Phase 10: 문서화 및 배포

### 10.1 관리자 매뉴얼
- [ ] 권한 설정 방법 문서화
- [ ] 폐쇄몰 활성화 방법 문서화

### 10.2 사용자 가이드
- [ ] 폐쇄몰 접근 방법 안내
- [ ] 주문 방법 안내

### 10.3 배포
- [ ] 운영 서버 배포
- [ ] 모니터링 설정

---

## 기술 스택 및 파일 구조

### 주요 수정 파일 예상 목록
```
adm/shop_admin/
  ├── closedmalllist.php            (신규 - 폐쇄몰 목록)
  ├── closedmallform.php            (신규 - 폐쇄몰 등록/수정)
  ├── closedmallformupdate.php      (신규 - 폐쇄몰 저장 처리)
  └── ajax_admin_closed_mall_*.php  (신규 - AJAX 유틸리티)

theme/kiwi/skin/shop/basic/
  ├── list.closed.skin.php          (신규 - 동적 생성 또는 설정 기반)
  ├── item.form.closed.skin.php     (신규 - 동적 생성 또는 설정 기반)
  └── style.css                     (수정 - 필요시)

shop/
  ├── closedmall.php                (신규 - 폐쇄몰 진입 페이지)
  ├── closedmall_list.php           (신규 - 폐쇄몰 상품 목록)
  ├── closedmall_item.php           (신규 - 폐쇄몰 상품 상세)
  ├── cart.php                      (수정 - 폐쇄몰 모드 감지)
  ├── cartupdate.php                (수정 - 폐쇄몰 모드 감지)
  ├── orderform.php                  (수정 - 폐쇄몰 모드 감지)
  ├── orderformupdate.php            (수정 - 폐쇄몰 모드 감지)
  └── orderinquiryview.php           (수정 - 폐쇄몰 모드 감지)

lib/
  └── closed_mall.lib.php           (신규 - 공통 함수)
```

### 데이터베이스 변경사항
- **신규 테이블**: `gom_mall_closed_malls` (폐쇄몰 설정 관리)
- 기존 테이블 활용
- 권한 테이블(`g5_auth_level`) 활용

---

## 주의사항

1. **기존 시스템과의 호환성**
   - 기존 일반 쇼핑몰 기능은 그대로 유지
   - 폐쇄몰은 별도 경로 또는 파라미터로 구분

2. **가격 계산 일관성**
   - 모든 페이지에서 동일한 가격 계산 로직 사용
   - AOV 관련 코드 완전 제거 또는 무시

3. **권한 관리**
   - 레벨별 권한과 회원별 권한 모두 지원
   - 권한 변경 시 즉시 반영

4. **보안**
   - 권한 체크는 모든 페이지에서 필수
   - URL 직접 접근 차단

---

## 개발 우선순위

1. **Highest Priority (필수 선행 작업)**
   - **Phase 0: 관리자 페이지 - 폐쇄몰 관리 시스템 구축**
     - 모든 사용자 페이지의 기반이 되는 설정 시스템
     - 반드시 먼저 완료해야 함

2. **High Priority**
   - Phase 1: 권한 시스템
   - Phase 2: 상품 진열
   - Phase 3: 상품 상세
   - Phase 5: 주문정보 입력

3. **Medium Priority**
   - Phase 4: 장바구니
   - Phase 6: 결제 진행
   - Phase 7: 주문 완료

4. **Low Priority**
   - Phase 8: 공통 수정
   - Phase 9: 테스트
   - Phase 10: 문서화

---

## 다음 단계

**Phase 0부터 순차적으로 개발을 진행합니다.**

Phase 0 완료 후, 설정된 폐쇄몰 정보를 기반으로 Phase 1 이후의 사용자 페이지를 개발합니다.

---

## Phase 0 상세 개발 계획

### 데이터베이스 스키마

```sql
CREATE TABLE IF NOT EXISTS `gom_mall_closed_malls` (
  `cm_id` int(11) NOT NULL AUTO_INCREMENT,
  `cm_title` varchar(255) NOT NULL DEFAULT '' COMMENT '폐쇄몰 제목',
  `cm_use` enum('Y','N') NOT NULL DEFAULT 'N' COMMENT '사용 여부',
  `cm_start_date` datetime DEFAULT NULL COMMENT '운영 시작일시',
  `cm_end_date` datetime DEFAULT NULL COMMENT '운영 종료일시',
  `cm_access_type` enum('member','level','code') NOT NULL DEFAULT 'level' COMMENT '접근 권한 타입',
  `cm_access_members` text COMMENT '접근 가능 회원 목록 (JSON)',
  `cm_access_levels` text COMMENT '접근 가능 레벨 목록 (JSON)',
  `cm_access_code` varchar(50) DEFAULT NULL COMMENT '입장 코드',
  `cm_product_type` enum('category','item','partner') NOT NULL DEFAULT 'category' COMMENT '진열 상품 타입',
  `cm_product_categories` text COMMENT '카테고리 목록 (JSON)',
  `cm_product_items` text COMMENT '상품코드 목록 (JSON)',
  `cm_product_partners` text COMMENT '파트너사 코드 목록 (JSON)',
  `cm_banner_image` varchar(255) DEFAULT NULL COMMENT '타이틀 이미지/배너',
  `cm_skin` varchar(100) NOT NULL DEFAULT 'list.10.skin.php' COMMENT '사용할 스킨',
  `cm_payment_methods` text COMMENT '결제 수단 (JSON)',
  `cm_pagination_type` enum('more','paging') NOT NULL DEFAULT 'paging' COMMENT '페이징 타입',
  `cm_reg_time` datetime NOT NULL COMMENT '등록일시',
  `cm_update_time` datetime DEFAULT NULL COMMENT '수정일시',
  PRIMARY KEY (`cm_id`),
  KEY `idx_cm_use` (`cm_use`),
  KEY `idx_cm_dates` (`cm_start_date`, `cm_end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='폐쇄몰 관리';
```

### 관리자 페이지 구조

```
adm/shop_admin/
  ├── closedmalllist.php          (목록)
  ├── closedmallform.php          (등록/수정 폼)
  ├── closedmallformupdate.php   (저장 처리)
  └── ajax_admin_closed_mall_*.php (AJAX 유틸리티)
```

### 설정 항목 상세

1. **기본 정보**
   - 제목: 텍스트 입력
   - 사용 여부: Y/N 체크박스

2. **운영 기간**
   - 시작일시: 날짜/시간 선택
   - 종료일시: 날짜/시간 선택
   - 무제한 옵션: 체크박스 (체크 시 종료일시 무시)

3. **접근 권한**
   - 타입 선택 (라디오):
     - 회원 선택: 멀티 셀렉트 또는 검색
     - 레벨 선택: 체크박스 (레벨 1~10)
     - 입장 코드: 텍스트 입력

4. **진열 상품**
   - 타입 선택 (라디오):
     - 카테고리: 트리 구조 멀티 셀렉트
     - 상품코드: 텍스트 영역 또는 검색
     - 파트너사: 멀티 셀렉트 또는 검색

5. **타이틀 이미지**
   - 파일 업로드
   - 이미지 미리보기
   - 삭제 기능

6. **스킨 선택**
   - 드롭다운: `theme/kiwi/skin/shop/basic/` 내 스킨 파일
   - 기본값: `list.10.skin.php`

7. **결제 수단**
   - 체크박스:
     - 무통장입금
     - 신용카드
     - 실시간계좌이체
     - 가상계좌
     - 휴대폰
     - 쿠폰
     - 포인트

8. **페이징 타입**
   - 라디오 버튼:
     - 더보기 (무한 스크롤)
     - 페이징 (페이지 번호)

### 사용자 페이지 연동

설정된 폐쇄몰 정보는 다음 Phase에서 사용:
- Phase 1: 권한 체크 시 `cm_access_type`, `cm_access_members`, `cm_access_levels`, `cm_access_code` 사용
- Phase 2: 상품 목록 시 `cm_product_type`, `cm_product_categories`, `cm_product_items`, `cm_product_partners`, `cm_skin`, `cm_pagination_type` 사용
- Phase 6: 결제 시 `cm_payment_methods` 사용

