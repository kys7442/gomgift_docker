# 사례 문의하기 API - Postman JSON RAW 예시 모음

## 개요
Postman에서 JSON RAW 형식으로 테스트할 수 있는 다양한 예시를 제공합니다.

---
POST /api/case_inquiry.php

## 📋 기본 설정

### Headers
```
Content-Type: application/json
Accept: application/json
```

### 회원인 경우 추가
```
Authorization: Bearer {access_token}
```

---

## 🧪 예시 1: 회원 문의 (최소 필수 필드만)

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "interior",
  "title": "인테리어 문의",
  "content": "인테리어 시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다."
}
```

---

## 🧪 예시 2: 회원 문의 (모든 필드 포함)

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "interior",
  "title": "풀옵션 주방분리 원룸 인테리어 문의",
  "content": "이 사례에 대해 문의드립니다. 인테리어 비용과 시공 기간이 궁금합니다. 추가로 원하는 스타일도 있습니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 123-45",
  "reservation_date": "2025-02-15",
  "case_id": "123"
}
```

---

## 🧪 예시 3: 비회원 문의 (최소 필수 필드만)

### Headers
```
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "construction",
  "title": "시공 문의",
  "content": "시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "contact": "010-1234-5678"
}
```

---

## 🧪 예시 4: 비회원 문의 (모든 필드 포함)

### Headers
```
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "construction",
  "title": "신축 건물 시공 문의",
  "content": "신축 건물 시공에 대해 문의드립니다. 견적을 받고 싶습니다. 상세 내용은 다음과 같습니다.",
  "contact": "010-1234-5678",
  "building_type": "주택/빌라",
  "sido": "경기도",
  "gugun": "수원시 영통구",
  "dong": "원천동 456-78",
  "reservation_date": "2025-03-01",
  "case_id": "456"
}
```

---

## 🧪 예시 5: 창호 카테고리 문의

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "window",
  "title": "창호 교체 문의",
  "content": "창호 교체에 대해 문의드립니다. 현재 창호 상태와 교체 비용이 궁금합니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "서초구",
  "dong": "반포동 789-12",
  "reservation_date": "2025-02-20",
  "case_id": "789"
}
```

---

## 🧪 예시 6: 부동산 카테고리 문의 (부동산계약여부 포함)

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "realty",
  "title": "부동산 매매 문의",
  "content": "부동산 매매에 대해 문의드립니다. 현재 계약 여부와 관련하여 상담 받고 싶습니다.",
  "building_type": "오피스텔",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 111-22",
  "realty_contract": "Y",
  "reservation_date": "2025-02-25",
  "case_id": "999"
}
```

---

## 🧪 예시 7: 주소 정보만 포함 (최소)

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "interior",
  "title": "인테리어 문의",
  "content": "인테리어 시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "sido": "서울특별시",
  "gugun": "강남구"
}
```

---

## 🧪 예시 8: 건물형태만 포함

### Headers
```
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "construction",
  "title": "시공 문의",
  "content": "시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "contact": "010-9876-5432",
  "building_type": "주택/빌라"
}
```

---

## 🧪 예시 9: 예약일만 포함

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "window",
  "title": "창호 문의",
  "content": "창호 교체에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "reservation_date": "2025-03-15"
}
```

---

## 🧪 예시 10: 사례 ID만 포함

### Headers
```
Authorization: Bearer {access_token}
Content-Type: application/json
```

### Body (raw JSON)
```json
{
  "category": "interior",
  "title": "인테리어 문의",
  "content": "이 사례에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "case_id": "12345"
}
```

---

## 📊 카테고리별 예시 요약

### 종합건설 (construction)
```json
{
  "category": "construction",
  "title": "시공 문의",
  "content": "시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 123-45"
}
```

### 인테리어 (interior)
```json
{
  "category": "interior",
  "title": "인테리어 문의",
  "content": "인테리어 시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "building_type": "주택/빌라",
  "sido": "경기도",
  "gugun": "수원시 영통구",
  "dong": "원천동 456-78"
}
```

### 창호 (window)
```json
{
  "category": "window",
  "title": "창호 교체 문의",
  "content": "창호 교체에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "building_type": "아파트",
  "sido": "서울특별시",
  "gugun": "서초구",
  "dong": "반포동 789-12"
}
```

### 부동산 (realty)
```json
{
  "category": "realty",
  "title": "부동산 문의",
  "content": "부동산 매매에 대해 문의드립니다. 상세 내용은 다음과 같습니다.",
  "building_type": "오피스텔",
  "sido": "서울특별시",
  "gugun": "강남구",
  "dong": "역삼동 111-22",
  "realty_contract": "Y"
}
```

---

## 🔍 에러 테스트 예시

### 필수 필드 누락 (category)
```json
{
  "title": "문의 제목",
  "content": "문의 내용입니다."
}
```

### 필수 필드 누락 (title)
```json
{
  "category": "interior",
  "content": "문의 내용입니다."
}
```

### 필수 필드 누락 (content)
```json
{
  "category": "interior",
  "title": "문의 제목"
}
```

### 비회원 연락처 누락
```json
{
  "category": "interior",
  "title": "문의 제목",
  "content": "문의 내용입니다."
}
```

### 유효하지 않은 카테고리
```json
{
  "category": "invalid_category",
  "title": "문의 제목",
  "content": "문의 내용입니다."
}
```

### 내용 길이 부족 (10자 미만)
```json
{
  "category": "interior",
  "title": "문의 제목",
  "content": "짧음"
}
```

---

## 📝 Postman Collection JSON (업데이트)

```json
{
  "info": {
    "name": "사례 문의하기 API (업데이트)",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    "description": "사례 문의하기 API 테스트 컬렉션 - 모든 필드 포함"
  },
  "item": [
    {
      "name": "회원 문의 (최소 필수)",
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
          "raw": "{\n  \"category\": \"interior\",\n  \"title\": \"인테리어 문의\",\n  \"content\": \"인테리어 시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    },
    {
      "name": "회원 문의 (모든 필드)",
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
          "raw": "{\n  \"category\": \"interior\",\n  \"title\": \"풀옵션 주방분리 원룸 인테리어 문의\",\n  \"content\": \"이 사례에 대해 문의드립니다. 인테리어 비용과 시공 기간이 궁금합니다.\",\n  \"building_type\": \"아파트\",\n  \"sido\": \"서울특별시\",\n  \"gugun\": \"강남구\",\n  \"dong\": \"역삼동 123-45\",\n  \"reservation_date\": \"2025-02-15\",\n  \"case_id\": \"123\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    },
    {
      "name": "비회원 문의 (최소 필수)",
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
          "raw": "{\n  \"category\": \"construction\",\n  \"title\": \"시공 문의\",\n  \"content\": \"시공에 대해 문의드립니다. 상세 내용은 다음과 같습니다.\",\n  \"contact\": \"010-1234-5678\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    },
    {
      "name": "비회원 문의 (모든 필드)",
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
          "raw": "{\n  \"category\": \"construction\",\n  \"title\": \"신축 건물 시공 문의\",\n  \"content\": \"신축 건물 시공에 대해 문의드립니다. 견적을 받고 싶습니다.\",\n  \"contact\": \"010-1234-5678\",\n  \"building_type\": \"주택/빌라\",\n  \"sido\": \"경기도\",\n  \"gugun\": \"수원시 영통구\",\n  \"dong\": \"원천동 456-78\",\n  \"reservation_date\": \"2025-03-01\",\n  \"case_id\": \"456\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/case_inquiry.php",
          "host": ["{{base_url}}"],
          "path": ["api", "case_inquiry.php"]
        }
      }
    },
    {
      "name": "부동산 문의 (부동산계약여부 포함)",
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
          "raw": "{\n  \"category\": \"realty\",\n  \"title\": \"부동산 매매 문의\",\n  \"content\": \"부동산 매매에 대해 문의드립니다. 현재 계약 여부와 관련하여 상담 받고 싶습니다.\",\n  \"building_type\": \"오피스텔\",\n  \"sido\": \"서울특별시\",\n  \"gugun\": \"강남구\",\n  \"dong\": \"역삼동 111-22\",\n  \"realty_contract\": \"Y\",\n  \"reservation_date\": \"2025-02-25\",\n  \"case_id\": \"999\"\n}"
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

## 💡 사용 팁

1. **환경 변수 설정**: Postman에서 `{{base_url}}`과 `{{access_token}}` 변수를 설정하여 재사용
2. **복사하여 사용**: 위 예시를 복사하여 Postman의 Body (raw JSON)에 붙여넣기
3. **필드 조합**: 필요에 따라 필드를 조합하여 사용
4. **에러 테스트**: 에러 예시를 사용하여 검증 로직 테스트

---

## 📞 문의

API 관련 문의사항이 있으시면 개발팀에 문의해주세요.

