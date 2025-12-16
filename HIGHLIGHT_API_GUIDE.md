# 성경 형광펜 API 가이드

## 개요

성경 형광펜(하이라이트) 기능은 **비회원과 회원 모두** 사용할 수 있습니다.

- **비회원**: 디바이스 고유 ID로 식별
- **회원**: JWT 토큰으로 인증
- **회원 가입 시**: 디바이스 ID의 형광펜이 회원 ID로 자동 연동

---

## 인증 방식

### 1. 비회원 인증
- **헤더**: `x-device-id: {디바이스ID}`
- **또는 Body**: `device_id: {디바이스ID}`
- 디바이스 ID는 앱 설치 시 생성된 고유 값 또는 디바이스 고유 ID

### 2. 회원 인증
- **헤더**: `Authorization: Bearer {JWT토큰}`
- 로그인 API에서 받은 토큰 사용

---

## API 엔드포인트

### 1. 형광펜 추가/업데이트
**POST** `/api/highlight/save`

**인증**: 회원 또는 비회원

**요청 본문:**
```json
{
  "book_code": 1,
  "chapter_code": 1,
  "verse_code": "1",
  "start_idx": 0,
  "end_idx": 10,
  "content_text": "태초에 하나님이 천지를 창조하시니라"
}
```

**응답:**
```json
{
  "success": true,
  "message": "형광펜이 추가되었습니다.",
  "data": {
    "id": 1,
    "mb_id": "device_abc123",
    "book_code": 1,
    "chapter_code": 1,
    "verse_code": "1",
    "start_idx": 0,
    "end_idx": 10,
    "content_text": "태초에 하나님이 천지를 창조하시니라",
    "created_at": "2024-01-15T10:30:00.000Z"
  }
}
```

---

### 2. 형광펜 삭제
**POST** `/api/highlight/delete`

**인증**: 회원 또는 비회원

**요청 본문 (ID로 삭제):**
```json
{
  "id": 1
}
```

**요청 본문 (위치 정보로 삭제):**
```json
{
  "book_code": 1,
  "chapter_code": 1,
  "verse_code": "1",
  "start_idx": 0,
  "end_idx": 10
}
```

**응답:**
```json
{
  "success": true,
  "message": "형광펜이 삭제되었습니다."
}
```

---

### 3. 형광펜 목록 조회
**GET** `/api/highlight/list`

**인증**: 회원 또는 비회원

**쿼리 파라미터:**
- `mode`: `chapter` (특정 장) 또는 `recent` (최근 목록)
- `book_code`: (mode='chapter'일 때 필수)
- `chapter_code`: (mode='chapter'일 때 필수)
- `limit`: (mode='recent'일 때 선택, 기본값: 5)

**예시 1: 특정 장 조회**
```
GET /api/highlight/list?mode=chapter&book_code=1&chapter_code=1
```

**응답:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "mb_id": "device_abc123",
      "book_code": 1,
      "chapter_code": 1,
      "verse_code": "1",
      "start_idx": 0,
      "end_idx": 10,
      "content_text": "태초에 하나님이 천지를 창조하시니라",
      "created_at": "2024-01-15T10:30:00.000Z"
    }
  ]
}
```

**예시 2: 최근 목록 조회**
```
GET /api/highlight/list?mode=recent&limit=5
```

**응답:**
```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "label": "누가복음 1장 2절",
      "content": "하나님께서 말씀하여...",
      "date": "2024-01-15",
      "book_code": 42,
      "chapter_code": 1,
      "verse_code": "2",
      "start_idx": 0,
      "end_idx": 20
    }
  ]
}
```

---

### 4. 형광펜이 표시된 장/책 목록 조회 (아이콘 표시용)
**GET** `/api/highlight/marked`

**인증**: 회원 또는 비회원

**쿼리 파라미터:**
- `book_code`: (선택) 특정 책의 장 목록만 조회

**예시 1: 특정 책의 형광펜이 있는 장 목록**
```
GET /api/highlight/marked?book_code=1
```

**응답:**
```json
{
  "success": true,
  "data": [
    { "chapter_code": 1, "highlight_count": 3 },
    { "chapter_code": 2, "highlight_count": 1 }
  ]
}
```

**예시 2: 모든 책의 형광펜이 있는 장 목록**
```
GET /api/highlight/marked
```

**응답:**
```json
{
  "success": true,
  "data": [
    {
      "book_code": 1,
      "chapters": [
        { "chapter_code": 1, "highlight_count": 3 },
        { "chapter_code": 2, "highlight_count": 1 }
      ]
    },
    {
      "book_code": 42,
      "chapters": [
        { "chapter_code": 1, "highlight_count": 2 }
      ]
    }
  ]
}
```

**용도:**
- 성경 목록 화면에서 형광펜이 있는 장에 아이콘 표시
- 성경 목록 화면에서 형광펜이 있는 책 표시

---

### 5. 디바이스 ID → 회원 ID 마이그레이션
**POST** `/api/highlight/migrate`

**인증**: 회원만 가능 (JWT 토큰 필수)

**요청 헤더:**
- `Authorization: Bearer {token}`
- `x-device-id: {디바이스ID}`

**요청 본문:**
```json
{
  "device_id": "device_abc123"
}
```

**응답:**
```json
{
  "success": true,
  "message": "형광펜이 회원 ID로 마이그레이션되었습니다.",
  "migrated_count": 5,
  "skipped_count": 0,
  "total_device_highlights": 5,
  "total_member_highlights": 5
}
```

**사용 시나리오:**
1. 비회원으로 형광펜 사용 (디바이스 ID로 저장)
2. 회원 가입
3. 로그인 후 이 API 호출하여 형광펜 데이터 연동

**주의사항:**
- 동일한 위치에 회원 ID로 이미 형광펜이 있으면 디바이스 ID의 것은 삭제됨
- 회원 ID의 형광펜이 우선

---

## Postman 테스트 가이드

### 1. Postman Collection Import
1. Postman 열기
2. **Import** 클릭
3. `postman_highlight_api.json` 파일 선택
4. 컬렉션이 추가됨

### 2. 환경 변수 설정
컬렉션 변수에서 다음을 설정:
- `base_url`: `http://localhost:3000` (또는 실제 서버 URL)
- `device_id`: 테스트용 디바이스 ID (예: `test-device-12345`)
- `token`: 로그인 후 받은 JWT 토큰 (회원 테스트용)

### 3. 비회원 테스트 시나리오

#### 3-1. 디바이스 ID 설정
1. 컬렉션 변수에서 `device_id`를 고정 값으로 설정
   - 예: `test-device-12345`
   - 에뮬레이터 테스트 시 동일한 값 사용 권장

#### 3-2. 형광펜 추가
1. **1. 형광펜 추가/업데이트 (비회원)** 요청 선택
2. `x-device-id` 헤더 확인 (자동 설정됨)
3. Body 수정:
   ```json
   {
     "book_code": 1,
     "chapter_code": 1,
     "verse_code": "1",
     "start_idx": 0,
     "end_idx": 10,
     "content_text": "태초에 하나님이 천지를 창조하시니라"
   }
   ```
4. **Send** 클릭
5. 응답에서 `id` 확인

#### 3-3. 형광펜 목록 조회
1. **4. 형광펜 목록 조회 - 특정 장 (비회원)** 요청 선택
2. **Send** 클릭
3. 추가한 형광펜이 목록에 표시되는지 확인

#### 3-4. 형광펜이 표시된 장 조회 (아이콘 표시용)
1. **6. 형광펜이 표시된 장/책 목록 조회** 요청 선택
2. `book_code=1` 쿼리 파라미터 확인
3. **Send** 클릭
4. `chapter_code: 1`이 응답에 포함되는지 확인

#### 3-5. 형광펜 삭제
1. **3. 형광펜 삭제 (비회원)** 요청 선택
2. Body에 위에서 받은 `id` 입력:
   ```json
   {
     "id": 1
   }
   ```
3. **Send** 클릭
4. 삭제 확인

### 4. 회원 테스트 시나리오

#### 4-1. 로그인하여 토큰 받기
1. 로그인 API 호출:
   ```
   POST /api/login
   Body: {
     "username": "testuser",
     "password": "testpass"
   }
   ```
2. 응답에서 `token` 복사
3. 컬렉션 변수 `token`에 붙여넣기

#### 4-2. 회원으로 형광펜 추가
1. **2. 형광펜 추가/업데이트 (회원)** 요청 선택
2. `Authorization` 헤더 확인 (자동 설정됨)
3. Body 수정 후 **Send**

#### 4-3. 마이그레이션 테스트
1. 비회원으로 형광펜 추가 (디바이스 ID 사용)
2. 회원 가입 및 로그인
3. **7. 디바이스 ID → 회원 ID 마이그레이션** 요청 선택
4. `x-device-id` 헤더에 비회원 시 사용한 디바이스 ID 입력
5. **Send** 클릭
6. `migrated_count` 확인
7. 회원 ID로 형광펜 목록 조회하여 연동 확인

### 5. 에뮬레이터 테스트 팁

#### 디바이스 ID 고정
- 에뮬레이터에서 앱을 삭제 후 재설치해도 동일한 디바이스 ID를 사용하도록 설정
- Postman에서 `device_id` 변수를 고정 값으로 설정하여 테스트

#### 테스트 순서
1. 비회원으로 형광펜 추가
2. 앱 삭제 시뮬레이션 (Postman에서 다른 디바이스 ID로 테스트)
3. 동일한 디바이스 ID로 다시 접속하여 형광펜 유지 확인
4. 회원 가입 및 마이그레이션
5. 회원 ID로 형광펜 연동 확인

---

## 데이터베이스 구조

### tb_bible_highlight 테이블
```sql
CREATE TABLE tb_bible_highlight (
  id INT AUTO_INCREMENT PRIMARY KEY,
  mb_id VARCHAR(50) NOT NULL,  -- 회원 ID 또는 "device_xxx" 형식
  book_code INT NOT NULL,
  chapter_code INT NOT NULL,
  verse_code VARCHAR(10) NOT NULL,
  start_idx INT NOT NULL,
  end_idx INT NOT NULL,
  content_text TEXT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_mb_id (mb_id),
  INDEX idx_mb_book_chapter (mb_id, book_code, chapter_code),
  INDEX idx_book_chapter (book_code, chapter_code),
  UNIQUE KEY uk_mb_location (mb_id, book_code, chapter_code, verse_code, start_idx, end_idx)
);
```

### mb_id 형식
- **회원**: 숫자 문자열 (예: `"1"`, `"2"`)
- **비회원**: `"device_"` 접두사 + 고유 ID (예: `"device_abc123"`)

---

## 에러 코드

| 에러 코드 | 설명 | HTTP 상태 |
|---------|------|----------|
| `MISSING_IDENTIFIER` | 디바이스 ID 또는 토큰이 없음 | 401 |
| `MISSING_PARAMETERS` | 필수 파라미터 누락 | 400 |
| `INVALID_PARAMETERS` | 잘못된 파라미터 값 | 400 |
| `INVALID_INDEX_RANGE` | 잘못된 인덱스 범위 | 400 |
| `HIGHLIGHT_NOT_FOUND` | 형광펜을 찾을 수 없음 | 404 |
| `INVALID_MODE` | 잘못된 mode 값 | 400 |
| `MISSING_DEVICE_ID` | 마이그레이션 시 디바이스 ID 없음 | 400 |

---

## 보안 고려사항

1. **SQL Injection 방지**: 모든 쿼리에 Prepared Statements 사용
2. **XSS 방지**: 입력값 검증 및 정규화
3. **권한 검증**: 본인의 형광펜만 조회/수정/삭제 가능
4. **디바이스 ID 검증**: 유효한 형식인지 확인

---

## 앱 연동 가이드

> **디바이스 ID 상세 가이드**: 플랫폼별 구현 방법은 `DEVICE_ID_GUIDE.md` 파일을 참고하세요.

### 1. 디바이스 ID 생성 및 관리

#### 플랫폼별 디바이스 ID 획득 방법

##### Android (Java/Kotlin)

**방법 1: ANDROID_ID 사용 (권장)**
```kotlin
import android.provider.Settings

// Kotlin
fun getDeviceId(context: Context): String {
    val androidId = Settings.Secure.getString(
        context.contentResolver,
        Settings.Secure.ANDROID_ID
    )
    return androidId ?: generateUUID()
}

// Java
public String getDeviceId(Context context) {
    String androidId = Settings.Secure.getString(
        context.getContentResolver(),
        Settings.Secure.ANDROID_ID
    );
    return androidId != null ? androidId : generateUUID();
}
```

**방법 2: UUID 생성 후 로컬 저장**
```kotlin
import java.util.UUID
import android.content.SharedPreferences

fun getOrCreateDeviceId(context: Context): String {
    val prefs = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
    var deviceId = prefs.getString("device_id", null)
    
    if (deviceId == null) {
        deviceId = UUID.randomUUID().toString()
        prefs.edit().putString("device_id", deviceId).apply()
    }
    
    return deviceId
}
```

##### iOS (Swift)

**방법 1: identifierForVendor 사용**
```swift
import UIKit

func getDeviceId() -> String {
    if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
        return vendorId
    } else {
        // 폴백: UUID 생성 후 UserDefaults에 저장
        return getOrCreateDeviceId()
    }
}

func getOrCreateDeviceId() -> String {
    let defaults = UserDefaults.standard
    if let deviceId = defaults.string(forKey: "device_id") {
        return deviceId
    } else {
        let newId = UUID().uuidString
        defaults.set(newId, forKey: "device_id")
        return newId
    }
}
```

**방법 2: UUID 생성 후 Keychain에 저장 (더 안전)**
```swift
import Security

func getOrCreateDeviceId() -> String {
    let keychainKey = "com.yourapp.device_id"
    
    // Keychain에서 읽기
    if let deviceId = readFromKeychain(key: keychainKey) {
        return deviceId
    }
    
    // 없으면 생성 후 저장
    let newId = UUID().uuidString
    saveToKeychain(key: keychainKey, value: newId)
    return newId
}
```

##### React Native

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';

// 방법 1: react-native-device-info 라이브러리 사용
async function getDeviceId() {
  try {
    // 기존에 저장된 ID가 있으면 사용
    let deviceId = await AsyncStorage.getItem('device_id');
    
    if (!deviceId) {
      // 새로 생성
      if (Platform.OS === 'android') {
        deviceId = await DeviceInfo.getAndroidId();
      } else {
        deviceId = DeviceInfo.getUniqueId();
      }
      
      // 없으면 UUID 생성
      if (!deviceId) {
        deviceId = generateUUID();
      }
      
      await AsyncStorage.setItem('device_id', deviceId);
    }
    
    return deviceId;
  } catch (error) {
    console.error('디바이스 ID 가져오기 실패:', error);
    return generateUUID();
  }
}

function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}
```

##### Flutter

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

Future<String> getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');
  
  if (deviceId == null) {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id; // ANDROID_ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }
    
    // 없으면 UUID 생성
    deviceId ??= _generateUUID();
    
    await prefs.setString('device_id', deviceId);
  }
  
  return deviceId;
}

String _generateUUID() {
  return '${_randomHex(8)}-${_randomHex(4)}-${_randomHex(4)}-${_randomHex(4)}-${_randomHex(12)}';
}

String _randomHex(int length) {
  final random = Random();
  return List.generate(length, (_) => random.nextInt(16).toRadixString(16)).join();
}
```

##### 웹 (PWA/웹앱)

```javascript
// localStorage 기반 UUID 생성 및 저장
function getOrCreateDeviceId() {
  let deviceId = localStorage.getItem('device_id');
  
  if (!deviceId) {
    // UUID v4 생성
    deviceId = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
    
    localStorage.setItem('device_id', deviceId);
  }
  
  return deviceId;
}
```

#### 디바이스 ID 저장 및 관리

**중요 사항:**
1. **로컬 저장소에 저장**: 앱 삭제 후 재설치 시에도 유지되도록
   - Android: SharedPreferences 또는 내부 저장소
   - iOS: UserDefaults 또는 Keychain (더 안전)
   - React Native: AsyncStorage
   - Flutter: SharedPreferences

2. **재설치 시 유지 방법:**
   - Android: 내부 저장소 또는 외부 저장소 사용
   - iOS: Keychain 사용 (앱 삭제 후에도 유지 가능)
   - 또는 서버에 백업 (선택사항)

3. **UUID 생성 규칙:**
   - UUID v4 형식 권장: `xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`
   - 또는 간단한 고유 문자열: `abc123-def456-ghi789`

#### API 호출 시 디바이스 ID 전달

```javascript
// React Native 예시
const deviceId = await getDeviceId();

// API 호출
fetch('http://your-api.com/api/highlight/save', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-device-id': deviceId  // 헤더로 전달
  },
  body: JSON.stringify({
    book_code: 1,
    chapter_code: 1,
    verse_code: "1",
    start_idx: 0,
    end_idx: 10,
    content_text: "태초에 하나님이..."
  })
});
```

```kotlin
// Android 예시
val deviceId = getOrCreateDeviceId()

val request = Request.Builder()
    .url("http://your-api.com/api/highlight/save")
    .addHeader("x-device-id", deviceId)
    .post(body)
    .build()
```

```swift
// iOS 예시
let deviceId = getOrCreateDeviceId()

var request = URLRequest(url: url)
request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
request.httpMethod = "POST"
request.httpBody = jsonData
```

### 2. 성경 목록 화면
- `/api/highlight/marked` API 호출
- 형광펜이 있는 장에 아이콘 표시
- 형광펜이 있는 책 표시

### 3. 성경 본문 상세 페이지
- 하단에 형광펜 목록 표시
- `/api/highlight/list?mode=chapter&book_code={book}&chapter_code={chapter}` 호출
- 각 형광펜에 삭제 버튼 제공

### 4. 회원 가입 플로우
1. 회원 가입 API 호출 시 `device_id` 포함 (자동 마이그레이션)
2. 또는 회원 가입 후 `/api/highlight/migrate` API 호출

---

## 문제 해결

### Q: 비회원 형광펜이 보이지 않아요
- 디바이스 ID가 올바르게 전달되는지 확인
- `x-device-id` 헤더 또는 `device_id` body 파라미터 확인

### Q: 회원 가입 후 형광펜이 사라졌어요
- `/api/highlight/migrate` API를 호출했는지 확인
- 회원 가입 API에 `device_id`를 포함했는지 확인

### Q: 동일한 위치에 형광펜이 중복 저장돼요
- UNIQUE 제약 조건으로 자동 방지됨
- 동일한 위치에 저장 시 업데이트됨

---

## 추가 기능 제안

1. **형광펜 색상**: 향후 확장 가능
2. **형광펜 메모**: 사용자 메모 추가 기능
3. **형광펜 공유**: 다른 사용자와 형광펜 공유
4. **형광펜 내보내기**: PDF 또는 텍스트로 내보내기

