# 사례 문의하기 API - Postman 테스트 가이드

## 개요
각 카테고리별 상세 페이지에서 "현재 사례를 문의하기" 기능을 테스트하는 가이드입니다.

---

## 📋 API 정보

### 엔드포인트
```
POST /api/case_inquiry.php
```

### 요청 방식
- **Method**: `POST`
- **Content-Type**: `application/json` 또는 `multipart/form-data`

### 인증
- **회원**: `Authorization: Bearer {access_token}` (필수)
- **비회원**: 인증 헤더 생략 가능

---

## 🧪 테스트 시나리오

### 시나리오 1: 회원 문의 등록 (성공)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
또는
http://test.intx.com/api/case_inquiry.php
```

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
Accept: application/json
```

**Body (raw JSON):**
```json
{
  "category": "interior",
  "title": "풀옵션 주방분리 원룸",
  "content": "이 사례에 대해 문의드립니다. 인테리어 비용과 시공 기간이 궁금합니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 123-45",
  "case_id": "123"
}
```

#### 예상 응답 (200 OK)
```json
{
  "success": true,
  "message": "문의가 등록되었습니다",
  "data": {
    "inquiry_id": 456,
    "category": "interior",
    "title": "풀옵션 주방분리 원룸",
    "status": "pending",
    "created_at": "2024-01-20 15:30:00"
  }
}
```

---

### 시나리오 2: 비회원 문의 등록 (성공)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
```

**Headers:**
```
Content-Type: application/json
Accept: application/json
```
⚠️ **주의**: `Authorization` 헤더 없음

**Body (raw JSON):**
```json
{
  "category": "construction",
  "title": "신축 건물 시공 문의",
  "content": "신축 건물 시공에 대해 문의드립니다. 견적을 받고 싶습니다.",
  "contact": "010-1234-5678",
  "building_type": "주택/빌라",
  "sido": "경기도",
  "gugun": "수원시 영통구",
  "dong": "원천동 456-78",
  "case_id": "456"
}
```

#### 예상 응답 (200 OK)
```json
{
  "success": true,
  "message": "문의가 등록되었습니다",
  "data": {
    "inquiry_id": 457,
    "category": "construction",
    "title": "신축 건물 시공 문의",
    "status": "pending",
    "created_at": "2024-01-20 15:35:00"
  }
}
```

---

### 시나리오 3: 필수 파라미터 누락 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "category": "interior"
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "입력값이 올바르지 않습니다",
  "errors": {
    "title": ["제목은 필수 항목입니다"],
    "content": ["상담 내용은 필수 항목입니다"]
  }
}
```

---

### 시나리오 4: 내용 길이 부족 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
```

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "category": "interior",
  "title": "문의 제목",
  "content": "짧음"
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "입력값이 올바르지 않습니다",
  "errors": {
    "content": ["상담 내용은 최소 10자 이상 입력해주세요"]
  }
}
```

---

### 시나리오 5: 비회원 연락처 누락 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
```

**Headers:**
```
Content-Type: application/json
```
⚠️ **주의**: `Authorization` 헤더 없음 (비회원)

**Body (raw JSON):**
```json
{
  "category": "interior",
  "title": "문의 제목",
  "content": "이 사례에 대해 문의드립니다. 인테리어 비용이 궁금합니다."
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "입력값이 올바르지 않습니다",
  "errors": {
    "contact": ["비회원은 연락처를 입력해주세요"]
  }
}
```

---

### 시나리오 6: 유효하지 않은 카테고리 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://www.int-x.co.kr/api/case_inquiry.php
```

**Headers:**
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "category": "invalid_category",
  "title": "문의 제목",
  "content": "이 사례에 대해 문의드립니다. 인테리어 비용이 궁금합니다."
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "입력값이 올바르지 않습니다",
  "errors": {
    "category": ["유효하지 않은 카테고리입니다"]
  }
}
```

---

## 📝 Postman 설정 단계별 가이드

### 1. 새 Request 생성

1. Postman 실행
2. **New** → **HTTP Request** 클릭
3. Method를 **POST**로 설정
4. URL 입력: `https://www.int-x.co.kr/api/case_inquiry.php`

### 2. Headers 설정

#### 회원인 경우:
```
Key: Authorization
Value: Bearer {access_token}
```

```
Key: Content-Type
Value: application/json
```

```
Key: Accept
Value: application/json
```

#### 비회원인 경우:
```
Key: Content-Type
Value: application/json
```

```
Key: Accept
Value: application/json
```

⚠️ **주의**: 비회원은 `Authorization` 헤더를 추가하지 않습니다.

### 3. Body 설정

#### 방법 1: JSON 형식 (권장)

1. **Body** 탭 선택
2. **raw** 선택
3. 드롭다운에서 **JSON** 선택
4. 아래 JSON 입력:

**회원용 (모든 필드 포함):**
```json
{
  "category": "interior",
  "title": "풀옵션 주방분리 원룸",
  "content": "이 사례에 대해 문의드립니다. 인테리어 비용과 시공 기간이 궁금합니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 123-45",
  "realty_contract": "N",
  "reservation_date": "2025-02-15",
  "case_id": "123"
}
```

**비회원용 (모든 필드 포함):**
```json
{
  "category": "construction",
  "title": "신축 건물 시공 문의",
  "content": "신축 건물 시공에 대해 문의드립니다. 견적을 받고 싶습니다.",
  "contact": "010-1234-5678",
  "building_type": "주택/빌라",
  "sido": "경기도",
  "gugun": "수원시 영통구",
  "dong": "원천동 456-78",
  "reservation_date": "2025-03-01",
  "case_id": "456"
}
```

**최소 필수 필드만 (회원):**
```json
{
  "category": "interior",
  "title": "인테리어 문의",
  "content": "인테리어 시공에 대해 문의드립니다. 상세 내용은..."
}
```

**최소 필수 필드만 (비회원):**
```json
{
  "category": "construction",
  "title": "시공 문의",
  "content": "시공에 대해 문의드립니다. 상세 내용은...",
  "contact": "010-1234-5678"
}
```

#### 방법 2: form-data 형식

1. **Body** 탭 선택
2. **form-data** 선택
3. 아래 필드 추가:

| Key | Value | Type | 필수 |
|-----|-------|------|------|
| category | interior | Text | ✅ |
| title | 풀옵션 주방분리 원룸 | Text | ✅ |
| content | 이 사례에 대해 문의드립니다... | Text | ✅ |
| contact | 010-1234-5678 | Text | 비회원만 ✅ |
| building_type | 아파트 | Text | ❌ |
| sido | 서울특별시 | Text | ❌ |
| gugun | 강남구 | Text | ❌ |
| dong | 역삼동 123-45 | Text | ❌ |
| realty_contract | N | Text | ❌ |
| reservation_date | 2025-02-15 | Text | ❌ |
| case_id | 123 | Text | ❌ |

### 4. 테스트 실행

1. **Send** 버튼 클릭
2. 응답 확인

---

## 🔑 Access Token 얻기

### 회원 로그인 API 사용

**엔드포인트:** `POST /api/member_login.php`

**요청:**
```json
{
  "mb_id": "admin",
  "mb_password": "your_password"
}
```

**응답에서 `access_token` 추출:**
```json
{
  "success": true,
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    ...
  }
}
```

---

## 📊 파라미터 상세 설명

### 필수 파라미터

| 파라미터 | 타입 | 설명 | 예시 | DB 필드 |
|---------|------|------|------|---------|
| `category` | string | 카테고리 (영문) | `construction`, `window`, `interior`, `realty` | `wr_1` (한글명으로 변환) |
| `title` | string | 상담 제목 | `"풀옵션 주방분리 원룸"` | `wr_content` (제목 포함) |
| `content` | string | 상담 내용 | 최소 10자, 최대 5000자 | `wr_content` |
| `contact` | string | 연락처 | 비회원 필수, 회원 선택 | `wr_tel` |

### 선택 파라미터

| 파라미터 | 타입 | 설명 | 예시 | DB 필드 |
|---------|------|------|------|---------|
| `building_type` | string | 건물형태 | `"아파트"`, `"주택/빌라"`, `"오피스텔"` | `wr_2` |
| `sido` | string | 시도 | `"서울특별시"`, `"경기도"` | `wr_3` |
| `gugun` | string | 구군 | `"강남구"`, `"수원시 영통구"` | `wr_4` |
| `dong` | string | 동/번지 | `"역삼동 123-45"` | `wr_5` |
| `realty_contract` | string | 부동산계약여부 | `"Y"`, `"N"` | `wr_6` |
| `reservation_date` | string | 예약일(희망) | `"2025-02-15"` | `wr_7` |
| `case_id` | string | 사례 ID | `"123"` | `wr_8` |

### 카테고리 매핑 (영문 → 한글)

| 영문 값 | 한글 값 (DB 저장) |
|--------|-----------------|
| `construction` | `종합건설` |
| `interior` | `인테리어` |
| `window` | `창호` |
| `realty` | `부동산` |

---

## ✅ 유효성 검증 규칙

### category
- **허용 값**: `construction`, `window`, `interior`, `realty`
- **필수**: ✅

### title
- **최대 길이**: 200자
- **필수**: ✅

### content
- **최소 길이**: 10자
- **최대 길이**: 5000자
- **필수**: ✅

### contact
- **형식**: 숫자와 하이픈 포함 가능 (예: `010-1234-5678`)
- **필수**: 비회원인 경우 ✅, 회원인 경우 ❌

### building_type
- **필수**: ❌
- **설명**: 건물형태 (예: 아파트, 주택/빌라, 오피스텔 등)
- **DB 필드**: `wr_2`

### sido
- **필수**: ❌
- **설명**: 시도 (예: 서울특별시, 경기도)
- **DB 필드**: `wr_3`

### gugun
- **필수**: ❌
- **설명**: 구군 (예: 강남구, 수원시 영통구)
- **DB 필드**: `wr_4`

### dong
- **필수**: ❌
- **설명**: 동/번지 (예: 역삼동 123-45)
- **DB 필드**: `wr_5`

### realty_contract
- **필수**: ❌
- **허용 값**: `"Y"`, `"N"`
- **설명**: 부동산계약여부 (부동산 카테고리일 때 의미 있음)
- **DB 필드**: `wr_6`

### reservation_date
- **필수**: ❌
- **형식**: 날짜 문자열 (예: `"2025-02-15"`)
- **설명**: 예약일(희망)
- **DB 필드**: `wr_7`

### case_id
- **필수**: ❌
- **설명**: 사례 ID (문의 대상 사례 식별용)
- **DB 필드**: `wr_8`

---

## 🧪 Postman Collection JSON

Postman에 Import하여 바로 사용할 수 있는 Collection:

```json
{
  "info": {
    "name": "사례 문의하기 API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "회원 문의 등록",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Authorization",
            "value": "Bearer {{access_token}}"
          },
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"category\": \"interior\",\n  \"title\": \"풀옵션 주방분리 원룸\",\n  \"content\": \"이 사례에 대해 문의드립니다. 인테리어 비용과 시공 기간이 궁금합니다.\",\n  \"building_type\": \"아파트\",\n  \"sido\": \"서울특별시\",\n  \"gugun\": \"강남구\",\n  \"dong\": \"역삼동 123-45\",\n  \"case_id\": \"123\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    },
    {
      "name": "비회원 문의 등록",
      "request": {
        "method": "POST",
        "header": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ],
        "body": {
          "mode": "raw",
          "raw": "{\n  \"category\": \"construction\",\n  \"title\": \"신축 건물 시공 문의\",\n  \"content\": \"신축 건물 시공에 대해 문의드립니다. 견적을 받고 싶습니다.\",\n  \"contact\": \"010-1234-5678\",\n  \"building_type\": \"주택/빌라\",\n  \"sido\": \"경기도\",\n  \"gugun\": \"수원시 영통구\",\n  \"dong\": \"원천동 456-78\",\n  \"case_id\": \"456\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "https://www.int-x.co.kr"
    },
    {
      "key": "access_token",
      "value": ""
    }
  ]
}
```

---

## 🔍 디버그 모드

SQL 에러를 확인하려면 요청에 `debug` 파라미터 추가:

**Query Params:**
```
debug=1
```

또는 Body에 추가:
```json
{
  "category": "interior",
  "title": "문의 제목",
  "content": "문의 내용...",
  "debug": true
}
```

---

## 📌 주의사항

1. **회원/비회원 구분**: JWT 토큰 유무로 판단
2. **연락처 필수**: 비회원인 경우 반드시 입력 필요
3. **내용 길이**: 최소 10자, 최대 5000자
4. **카테고리**: 4가지 카테고리만 허용 (`construction`, `window`, `interior`, `realty`)
   - 서버에서 자동으로 한글명으로 변환하여 DB에 저장
   - `construction` → `종합건설`
   - `interior` → `인테리어`
   - `window` → `창호`
   - `realty` → `부동산`
5. **주소 정보**: `sido`, `gugun`, `dong`은 선택사항이지만, 모두 입력하는 것을 권장
6. **제목과 내용**: `title`과 `content`는 `wr_content` 필드에 함께 저장됨 (형식: `"{title}\n\n{content}"`)
7. **부동산계약여부**: `realty` 카테고리일 때만 의미가 있음 (`"Y"` 또는 `"N"`)

---

## 🎯 빠른 테스트 체크리스트

- [ ] 회원 문의 등록 (성공)
- [ ] 비회원 문의 등록 (성공)
- [ ] 필수 파라미터 누락 (400 에러)
- [ ] 내용 길이 부족 (400 에러)
- [ ] 비회원 연락처 누락 (400 에러)
- [ ] 유효하지 않은 카테고리 (400 에러)
- [ ] 유효하지 않은 토큰 (401 에러)

---

## 💡 팁

1. **환경 변수 사용**: Postman에서 `{{base_url}}`, `{{access_token}}` 변수 사용 권장
2. **Pre-request Script**: 로그인 API를 먼저 호출하여 토큰 자동 저장
3. **Tests Script**: 응답 검증 자동화

### Pre-request Script 예시 (토큰 자동 저장)
```javascript
// 로그인 API 호출하여 토큰 저장
pm.sendRequest({
    url: pm.environment.get("base_url") + '/api/member_login.php',
    method: 'POST',
    header: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + pm.environment.get("api_token")
    },
    body: {
        mode: 'raw',
        raw: JSON.stringify({
            mb_id: 'admin',
            mb_password: 'your_password'
        })
    }
}, function (err, res) {
    if (res.json().success) {
        pm.environment.set("access_token", res.json().data.access_token);
    }
});
```

---

## 📞 문의

API 관련 문의사항이 있으시면 개발팀에 문의해주세요.

