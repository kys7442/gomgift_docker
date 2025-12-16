# SNS 로그인 API 설정 가이드

## 개요
구글, 네이버, 카카오, Apple SNS 로그인을 그누보드5와 연동하기 위한 API입니다.

---

## 1. 데이터베이스 설정

### g5_member 테이블에 SNS 컬럼 추가

SNS 로그인을 위해 다음 컬럼을 추가해야 합니다:

```sql
ALTER TABLE g5_member 
ADD COLUMN mb_sns_type VARCHAR(20) DEFAULT NULL COMMENT 'SNS 타입: google, naver, kakao, apple',
ADD COLUMN mb_sns_id VARCHAR(255) DEFAULT NULL COMMENT 'SNS 고유 ID',
ADD INDEX idx_sns (mb_sns_type, mb_sns_id);
```

**주의**: 컬럼이 없어도 API는 동작하지만, SNS 정보가 저장되지 않습니다.

---

## 2. API 엔드포인트

### 2.1 SNS 토큰 직접 연동
```
POST /api/member_sns_login.php
```
- Google / Naver / Kakao / Apple SDK에서 전달받은 토큰을 그대로 서버에 전달
- **선택사항**: API 토큰 (보안 강화를 위해 사용 가능)

### 2.2 Firebase 인증 연동
```
POST /api/member_firebase_login.php
```
- Firebase Authentication에서 발급한 `id_token`을 서버에 전달
- 서버 측 `.env` 또는 환경변수에 `FIREBASE_API_KEY` 설정 필요
  - Firebase 프로젝트 설정 > 웹 API 키 사용
- 기본적으로 토큰 없이도 사용 가능 (Firebase 토큰 검증으로 대체 가능)

---

## 3. 요청 파라미터

### 필수 파라미터

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `sns_type` | string | SNS 타입: `google`, `naver`, `kakao`, `apple` |
| `sns_id` | string | SNS 고유 ID (각 SNS에서 제공하는 사용자 고유 식별자) |

### 선택 파라미터

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `email` | string | 이메일 주소 |
| `name` | string | 사용자 이름 (닉네임 또는 실명) |
| `photo_url` | string | 프로필 사진 URL |
| `access_token` | string | SNS Access Token (서버에서 검증에 사용) |
| `id_token` | string | Google ID Token (Google 전용) |
| `identity_token` | string | Apple Identity Token (Apple 전용) |
| `authorization_code` | string | Apple Authorization Code (Apple 전용) |

### Firebase 로그인 (member_firebase_login.php)

| 파라미터 | 타입 | 설명 |
|---------|------|------|
| `id_token` | string | **필수**. Firebase Authentication ID Token |
| `provider` | string | (선택) Firebase providerId, 예: `google.com`, `password`, `apple.com` |
| `email` | string | (선택) 이메일 주소. 토큰에 없을 때 전달 |
| `name` | string | (선택) 표시 이름 |
| `photo_url` | string | (선택) 프로필 이미지 URL |

---

## 4. 요청 예시

### Google 로그인
```json
{
  "sns_type": "google",
  "sns_id": "12345678901234567890",
  "email": "user@gmail.com",
  "name": "홍길동",
  "photo_url": "https://lh3.googleusercontent.com/...",
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "access_token": "ya29.a0AfH6SMC..."
}
```

### 네이버 로그인
```json
{
  "sns_type": "naver",
  "sns_id": "abc123def456",
  "email": "user@naver.com",
  "name": "홍길동",
  "photo_url": "https://phinf.pstatic.net/...",
  "access_token": "AAAAO..."
}
```

### 카카오 로그인
```json
{
  "sns_type": "kakao",
  "sns_id": "12345678",
  "email": "user@kakao.com",
  "name": "홍길동",
  "photo_url": "http://k.kakaocdn.net/...",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Apple 로그인
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

### Firebase 로그인 (앱)
```json
{
  "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
  "provider": "google.com",
  "email": "user@gmail.com",
  "name": "홍길동",
  "photo_url": "https://lh3.googleusercontent.com/..."
}
```

---

## 5. 응답 형식

### 성공 응답 (200 OK)
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
    "mb_id": "user123",
    "mb_name": "홍길동",
    "mb_email": "user@example.com",
    "mb_level": 1,
    "mb_role": "user"
  }
}
```

### 실패 응답 (400 Bad Request)
```json
{
  "success": false,
  "message": "필수 파라미터가 누락되었습니다.",
  "data": null
}
```

### 실패 응답 (401 Unauthorized)
```json
{
  "success": false,
  "message": "SNS 토큰 검증 실패",
  "data": null
}
```

---

## 6. 동작 방식

### 기존 회원인 경우
1. `mb_sns_type`과 `mb_sns_id`로 회원 조회
2. 회원이 존재하면 로그인 처리
3. 이메일, 이름, 프로필 사진이 업데이트되었으면 자동 업데이트
4. JWT 토큰 및 Refresh 토큰 발급

### 신규 회원인 경우
1. 이메일이 있으면 이메일 기반으로 `mb_id` 생성
2. 이메일이 없으면 SNS ID 기반으로 `mb_id` 생성
3. 중복 체크 후 자동 회원가입
4. `mb_email_certify`를 현재 날짜/시간으로 설정 (SNS 로그인은 이메일 인증 완료로 간주)
5. JWT 토큰 및 Refresh 토큰 발급

### Firebase 인증 흐름
1. 앱에서 Firebase Authentication으로 로그인하여 `id_token` 획득
2. `POST /api/member_firebase_login.php` 호출 시 `id_token` 전달
3. 서버에서 `FIREBASE_API_KEY`로 Firebase REST API를 통해 토큰 검증
4. 검증 성공 시 `providerId`에 따라 `mb_sns_type`을 `google`, `firebase_email`, `firebase_phone` 등으로 저장
5. 기존 회원이면 로그인, 없으면 자동 회원가입 후 JWT/Refresh 토큰 발급

---

## 7. 회원 ID 생성 규칙

### 이메일이 있는 경우
- 이메일의 @ 앞부분을 사용
- 특수문자 제거
- 최대 20자로 제한
- 중복 시 SNS ID 일부 추가

### 이메일이 없는 경우
- `{sns_type}_{sns_id}` 형식
- 최대 20자로 제한
- 중복 시 타임스탬프 추가

---

## 8. SNS 토큰 검증 (선택사항)

보안을 강화하려면 서버에서 SNS 토큰을 검증하는 것을 권장합니다.

Firebase 인증을 사용할 경우, `.env` 또는 서버 환경변수에 `FIREBASE_API_KEY`를 설정하고 `verify_firebase_id_token()` 함수를 통해 ID 토큰을 검증합니다. 이 API 키는 Firebase 콘솔의 **프로젝트 설정 > 일반 > 웹 API 키**에서 확인할 수 있습니다.

### Google 토큰 검증
```php
function verify_google_token($id_token) {
    $url = "https://oauth2.googleapis.com/tokeninfo?id_token=" . urlencode($id_token);
    $response = file_get_contents($url);
    $token_info = json_decode($response, true);
    
    if ($token_info && isset($token_info['sub'])) {
        return $token_info;
    }
    return false;
}
```

### 네이버 토큰 검증
```php
function verify_naver_token($access_token) {
    $url = "https://openapi.naver.com/v1/nid/me";
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer " . $access_token
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $user_info = json_decode($response, true);
    if ($user_info && $user_info['resultcode'] === '00') {
        return $user_info['response'];
    }
    return false;
}
```

### 카카오 토큰 검증
```php
function verify_kakao_token($access_token) {
    $url = "https://kapi.kakao.com/v2/user/me";
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Authorization: Bearer " . $access_token
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    
    $user_info = json_decode($response, true);
    if ($user_info && isset($user_info['id'])) {
        return $user_info;
    }
    return false;
}
```

---

## 9. 프론트엔드 연동

### JavaScript 라이브러리 사용

프로젝트에 포함된 `js/sns_login_api.js` 파일을 사용하여 쉽게 SNS 로그인을 구현할 수 있습니다.

#### HTML에 스크립트 추가
```html
<script src="/js/sns_login_api.js"></script>
```

#### Google 로그인 예제
```javascript
// Google Sign-In SDK 초기화 후
function onGoogleSignIn(googleUser) {
    googleLogin(googleUser)
        .then(function(response) {
            console.log('로그인 성공:', response.data);
            // 로그인 성공 후 처리 (페이지 이동 등)
            window.location.href = '/';
        })
        .catch(function(error) {
            console.error('로그인 실패:', error);
            alert('로그인에 실패했습니다: ' + error.message);
        });
}
```

#### 네이버 로그인 예제
```javascript
// 네이버 로그인 SDK 초기화 후
function onNaverLogin(naverUser, accessToken) {
    naverLogin(naverUser, accessToken)
        .then(function(response) {
            console.log('로그인 성공:', response.data);
            window.location.href = '/';
        })
        .catch(function(error) {
            console.error('로그인 실패:', error);
            alert('로그인에 실패했습니다: ' + error.message);
        });
}
```

#### 카카오 로그인 예제
```javascript
// 카카오 로그인 SDK 초기화 후
function onKakaoLogin(kakaoUser, accessToken) {
    kakaoLogin(kakaoUser, accessToken)
        .then(function(response) {
            console.log('로그인 성공:', response.data);
            window.location.href = '/';
        })
        .catch(function(error) {
            console.error('로그인 실패:', error);
            alert('로그인에 실패했습니다: ' + error.message);
        });
}
```

#### Apple 로그인 예제
```javascript
// Apple 로그인 SDK 초기화 후
function onAppleLogin(appleUser, identityToken, authorizationCode) {
    appleLogin(appleUser, identityToken, authorizationCode)
        .then(function(response) {
            console.log('로그인 성공:', response.data);
            window.location.href = '/';
        })
        .catch(function(error) {
            console.error('로그인 실패:', error);
            alert('로그인에 실패했습니다: ' + error.message);
        });
}
```

#### 직접 API 호출 예제
```javascript
// 직접 API 호출
snsLogin({
    sns_type: 'google',
    sns_id: '12345678901234567890',
    email: 'user@gmail.com',
    name: '홍길동',
    photo_url: 'https://lh3.googleusercontent.com/...',
    id_token: 'eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...',
    access_token: 'ya29.a0AfH6SMC...'
})
.then(function(response) {
    console.log('로그인 성공:', response);
})
.catch(function(error) {
    console.error('로그인 실패:', error);
});
```

#### 토큰 관리
```javascript
// 저장된 토큰 가져오기
var accessToken = getAccessToken();
var refreshToken = getRefreshToken();

// 로그아웃 (토큰 제거)
snsLogout();
```

#### Firebase 인증 연동 (웹)
Firebase Web SDK에서 로그인 완료 후 `firebaseLogin` 함수를 호출해 서버와 동기화합니다.

```javascript
firebase.auth().signInWithPopup(googleProvider)
  .then(async function(result) {
      const user = result.user;
      const idToken = await user.getIdToken();

      firebaseLogin(idToken, {
          email: user.email,
          name: user.displayName,
          photo_url: user.photoURL,
          provider: result.credential && result.credential.providerId
      })
      .then(function(response) {
          console.log('Firebase 로그인 성공:', response.data);
          window.location.href = '/';
      })
      .catch(function(error) {
          alert('서버 로그인 실패: ' + error.message);
      });
  })
  .catch(function(error) {
      console.error('Firebase 인증 실패:', error);
  });
```

### React Native / 모바일 앱 연동

모바일 앱에서는 직접 fetch API를 사용하여 호출할 수 있습니다:

```javascript
async function snsLoginMobile(params) {
    try {
        const response = await fetch('https://your-domain.com/api/member_sns_login.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify(params)
        });
        
        const data = await response.json();
        
        if (data.success) {
            // 토큰 저장 (AsyncStorage 등)
            await AsyncStorage.setItem('access_token', data.data.access_token);
            if (data.data.refresh_token) {
                await AsyncStorage.setItem('refresh_token', data.data.refresh_token);
            }
            return data;
        } else {
            throw new Error(data.message || '로그인에 실패했습니다.');
        }
    } catch (error) {
        throw error;
    }
}
```

### Firebase Auth 연동 (모바일 공통)
Firebase SDK로 로그인한 뒤 발급된 `idToken`을 서버에 전달해 회원 정보를 동기화합니다.

```javascript
async function syncFirebaseLogin(idToken, profile = {}) {
    const response = await fetch('https://your-domain.com/api/member_firebase_login.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=utf-8'
        },
        body: JSON.stringify({
            id_token: idToken,
            email: profile.email,
            name: profile.name,
            photo_url: profile.photoURL,
            provider: profile.providerId
        })
    });

    const data = await response.json();
    if (!data.success) {
        throw new Error(data.message || 'Firebase 로그인 동기화 실패');
    }
    return data;
}
```

---

## 10. 테스트 방법

### Postman 테스트

1. **Headers 설정**:
   - `Content-Type`: `application/json`
   - (선택) `Authorization`: `Bearer {API_TOKEN}`

2. **Body (raw JSON)**:
   ```json
   {
     "sns_type": "google",
     "sns_id": "test_google_id_12345",
     "email": "test@example.com",
     "name": "테스트 사용자",
     "photo_url": "https://example.com/photo.jpg"
   }
   ```

3. **응답 확인**: 성공 시 JWT 토큰과 사용자 정보가 반환됩니다.

---

## 11. 주의사항

1. **SNS 토큰 검증**: 보안을 강화하려면 서버에서 SNS 토큰을 검증하는 것을 권장합니다.
2. **중복 가입 방지**: 같은 이메일로 여러 SNS 계정이 가입되는 것을 방지하려면 이메일 기반 중복 체크를 추가할 수 있습니다.
3. **프로필 사진**: `photo_url`은 `mb_icon` 컬럼에 저장됩니다 (컬럼이 있는 경우).
4. **비밀번호**: SNS 로그인 사용자는 랜덤 비밀번호가 생성되지만, 실제로는 사용하지 않습니다.
5. **이메일 인증**: SNS 로그인 사용자는 `mb_email_certify`가 현재 날짜/시간으로 자동 설정됩니다 (그누보드5 표준 형식).

---

## 12. 데이터베이스 확인

### SNS 로그인 회원 조회
```sql
SELECT mb_id, mb_name, mb_email, mb_sns_type, mb_sns_id, mb_datetime 
FROM g5_member 
WHERE mb_sns_type IS NOT NULL 
ORDER BY mb_datetime DESC;
```

### 특정 SNS 타입 회원 조회
```sql
SELECT mb_id, mb_name, mb_email, mb_sns_id 
FROM g5_member 
WHERE mb_sns_type = 'google';
```

---

## 13. 문제 해결

### 회원가입 실패
- 데이터베이스 컬럼 확인
- SQL 에러 로그 확인
- mb_id 중복 확인

### 토큰 발급 실패
- JWT 설정 확인 (`_common.php`의 `API_JWT_SECRET`)
- 데이터베이스 연결 확인

### SNS 정보 저장 안됨
- `mb_sns_type`, `mb_sns_id` 컬럼이 추가되었는지 확인
- 컬럼이 없으면 위의 SQL을 실행하여 추가

---

## 문의사항

SNS 로그인 API 관련 문제가 있으시면 개발팀에 문의해주세요.

