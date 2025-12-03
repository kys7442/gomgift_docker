# SNS 로그인 API - Postman 테스트 가이드

## 개요
구글, 네이버, 카카오, Apple SNS 로그인 API를 Postman에서 테스트하는 가이드입니다.

---

## 📋 API 정보

### 엔드포인트
```
POST /api/member_sns_login.php
```

### 요청 방식
- **Method**: `POST`
- **Content-Type**: `application/json`

### 인증
- **선택사항**: API 토큰 (보안 강화 시 사용)
- 기본적으로 토큰 없이도 사용 가능

---

## 🧪 테스트 시나리오

### 시나리오 1: Google 로그인 (신규 회원)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
또는
http://test.modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
Accept: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "google",
  "sns_id": "12345678901234567890",
  "email": "test@gmail.com",
  "name": "테스트 사용자",
  "photo_url": "https://lh3.googleusercontent.com/a/default-user",
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "access_token": "ya29.a0AfH6SMC..."
}
```

#### 예상 응답 (200 OK)
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_expires_at": "2025-01-15 14:30:00",
    "mb_id": "test",
    "mb_name": "테스트 사용자",
    "mb_email": "test@gmail.com",
    "mb_level": 1,
    "mb_role": "user"
  }
}
```

---

### 시나리오 2: 네이버 로그인 (기존 회원)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "naver",
  "sns_id": "abc123def456",
  "email": "user@naver.com",
  "name": "홍길동",
  "photo_url": "https://phinf.pstatic.net/example.jpg",
  "access_token": "AAAAO..."
}
```

#### 예상 응답 (200 OK)
```json
{
  "success": true,
  "message": "로그인 성공",
  "data": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "token_type": "Bearer",
    "expires_in": 3600,
    "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_expires_at": "2025-01-15 14:30:00",
    "mb_id": "user",
    "mb_name": "홍길동",
    "mb_email": "user@naver.com",
    "mb_level": 1,
    "mb_role": "user"
  }
}
```

---

### 시나리오 3: 카카오 로그인

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "kakao",
  "sns_id": "12345678",
  "email": "user@kakao.com",
  "name": "홍길동",
  "photo_url": "http://k.kakaocdn.net/example.jpg",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 시나리오 4: Apple 로그인

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "apple",
  "sns_id": "001234.567890abcdef.1234",
  "email": "user@privaterelay.appleid.com",
  "name": "홍길동",
  "identity_token": "eyJraWQiOiJlWGF1bm1...",
  "authorization_code": "c1234567890abcdef..."
}
```

---

### 시나리오 5: 필수 파라미터 누락 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "google"
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "sns_type과 sns_id는 필수 파라미터입니다.",
  "data": null
}
```

---

### 시나리오 6: 유효하지 않은 SNS 타입 (실패)

#### 요청 설정

**Method:** `POST`

**URL:**
```
https://modusigong.com/api/member_sns_login.php
```

**Headers:**
```
Content-Type: application/json
```

**Body (raw JSON):**
```json
{
  "sns_type": "facebook",
  "sns_id": "123456789"
}
```

#### 예상 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "지원하지 않는 SNS 타입입니다. (google, naver, kakao, apple만 지원)",
  "data": null
}
```

---

## 📝 Postman 설정 단계별 가이드

### 1. 새 Request 생성

1. Postman 실행
2. **New** → **HTTP Request** 클릭
3. Method를 **POST**로 설정
4. URL 입력: `https://modusigong.com/api/member_sns_login.php`

### 2. Headers 설정

```
Key: Content-Type
Value: application/json
```

```
Key: Accept
Value: application/json
```

(선택) API 토큰 사용 시:
```
Key: Authorization
Value: Bearer {API_TOKEN}
```

### 3. Body 설정

1. **Body** 탭 선택
2. **raw** 선택
3. 드롭다운에서 **JSON** 선택
4. 아래 JSON 입력:

**Google 로그인 예시:**
```json
{
  "sns_type": "google",
  "sns_id": "12345678901234567890",
  "email": "test@gmail.com",
  "name": "테스트 사용자",
  "photo_url": "https://example.com/photo.jpg"
}
```

**네이버 로그인 예시:**
```json
{
  "sns_type": "naver",
  "sns_id": "abc123def456",
  "email": "user@naver.com",
  "name": "홍길동",
  "access_token": "AAAAO..."
}
```

**카카오 로그인 예시:**
```json
{
  "sns_type": "kakao",
  "sns_id": "12345678",
  "email": "user@kakao.com",
  "name": "홍길동"
}
```

**Apple 로그인 예시:**
```json
{
  "sns_type": "apple",
  "sns_id": "001234.567890abcdef.1234",
  "email": "user@privaterelay.appleid.com",
  "name": "홍길동",
  "identity_token": "eyJraWQiOiJlWGF1bm1..."
}
```

### 4. 테스트 실행

1. **Send** 버튼 클릭
2. 응답 확인

---

## 🧪 Postman Collection JSON

Postman에 Import하여 바로 사용할 수 있는 Collection:

```json
{
  "info": {
    "name": "SNS 로그인 API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    "description": "구글, 네이버, 카카오, Apple SNS 로그인 API 테스트"
  },
  "item": [
    {
      "name": "Google 로그인",
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
          "raw": "{\n  \"sns_type\": \"google\",\n  \"sns_id\": \"12345678901234567890\",\n  \"email\": \"test@gmail.com\",\n  \"name\": \"테스트 사용자\",\n  \"photo_url\": \"https://example.com/photo.jpg\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/member_sns_login.php",
          "host": ["{{base_url}}"],
          "path": ["api", "member_sns_login.php"]
        }
      }
    },
    {
      "name": "네이버 로그인",
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
          "raw": "{\n  \"sns_type\": \"naver\",\n  \"sns_id\": \"abc123def456\",\n  \"email\": \"user@naver.com\",\n  \"name\": \"홍길동\",\n  \"photo_url\": \"https://example.com/photo.jpg\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/member_sns_login.php",
          "host": ["{{base_url}}"],
          "path": ["api", "member_sns_login.php"]
        }
      }
    },
    {
      "name": "카카오 로그인",
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
          "raw": "{\n  \"sns_type\": \"kakao\",\n  \"sns_id\": \"12345678\",\n  \"email\": \"user@kakao.com\",\n  \"name\": \"홍길동\",\n  \"photo_url\": \"https://example.com/photo.jpg\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/member_sns_login.php",
          "host": ["{{base_url}}"],
          "path": ["api", "member_sns_login.php"]
        }
      }
    },
    {
      "name": "Apple 로그인",
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
          "raw": "{\n  \"sns_type\": \"apple\",\n  \"sns_id\": \"001234.567890abcdef.1234\",\n  \"email\": \"user@privaterelay.appleid.com\",\n  \"name\": \"홍길동\",\n  \"identity_token\": \"eyJraWQiOiJlWGF1bm1...\"\n}"
        },
        "url": {
          "raw": "{{base_url}}/api/member_sns_login.php",
          "host": ["{{base_url}}"],
          "path": ["api", "member_sns_login.php"]
        }
      }
    }
  ],
  "variable": [
    {
      "key": "base_url",
      "value": "https://modusigong.com"
    }
  ]
}
```

---

## 📊 파라미터 상세 설명

### 필수 파라미터

| 파라미터 | 타입 | 설명 | 예시 |
|---------|------|------|------|
| `sns_type` | string | SNS 타입 | `"google"`, `"naver"`, `"kakao"`, `"apple"` |
| `sns_id` | string | SNS 고유 ID | `"12345678901234567890"` |

### 선택 파라미터

| 파라미터 | 타입 | 설명 | 예시 |
|---------|------|------|------|
| `email` | string | 이메일 주소 | `"user@example.com"` |
| `name` | string | 사용자 이름 | `"홍길동"` |
| `photo_url` | string | 프로필 사진 URL | `"https://example.com/photo.jpg"` |
| `access_token` | string | SNS Access Token | `"ya29.a0AfH6SMC..."` |
| `id_token` | string | Google ID Token (Google 전용) | `"eyJhbGciOiJSUzI1NiIs..."` |
| `identity_token` | string | Apple Identity Token (Apple 전용) | `"eyJraWQiOiJlWGF1bm1..."` |
| `authorization_code` | string | Apple Authorization Code (Apple 전용) | `"c1234567890abcdef..."` |

---

## ✅ 유효성 검증 규칙

### sns_type
- **허용 값**: `google`, `naver`, `kakao`, `apple`
- **필수**: ✅

### sns_id
- **필수**: ✅
- **설명**: 각 SNS에서 제공하는 사용자 고유 식별자

### email
- **필수**: ❌
- **설명**: 이메일이 있으면 이메일 기반으로 mb_id 생성

### name
- **필수**: ❌
- **기본값**: `"SNS회원"` (없는 경우)

---

## 🎯 빠른 테스트 체크리스트

- [ ] Google 로그인 (신규 회원)
- [ ] 네이버 로그인 (신규 회원)
- [ ] 카카오 로그인 (신규 회원)
- [ ] Apple 로그인 (신규 회원)
- [ ] 기존 회원 로그인 (같은 sns_id로 재요청)
- [ ] 필수 파라미터 누락 (400 에러)
- [ ] 유효하지 않은 SNS 타입 (400 에러)
- [ ] 이메일 없이 로그인 (SNS ID 기반 mb_id 생성)

---

## 💡 팁

1. **환경 변수 사용**: Postman에서 `{{base_url}}` 변수 사용 권장
2. **토큰 저장**: 로그인 성공 후 `access_token`을 환경 변수에 저장하여 다른 API 테스트에 사용
3. **중복 테스트**: 같은 `sns_id`로 여러 번 요청하여 기존 회원 로그인 테스트

### Pre-request Script 예시 (토큰 자동 저장)
```javascript
// 로그인 성공 후 토큰 저장
if (pm.response.code === 200) {
    var jsonData = pm.response.json();
    if (jsonData.success && jsonData.data.access_token) {
        pm.environment.set("access_token", jsonData.data.access_token);
        pm.environment.set("refresh_token", jsonData.data.refresh_token);
    }
}
```

---

## 📞 문의

API 관련 문의사항이 있으시면 개발팀에 문의해주세요.

