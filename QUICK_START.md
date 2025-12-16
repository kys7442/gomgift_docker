# 형광펜 기능 빠른 시작 가이드

## 🎯 지금 바로 해야 할 일

### 상황 1: 모바일 앱 개발자라면

#### 1단계: 디바이스 ID 생성 함수 추가

앱의 유틸리티 파일에 다음 코드를 추가하세요:

**React Native:**
```javascript
// utils/deviceId.js
import AsyncStorage from '@react-native-async-storage/async-storage';

export async function getOrCreateDeviceId() {
  // 1. 저장된 ID 확인
  let deviceId = await AsyncStorage.getItem('device_id');
  
  if (deviceId) {
    return deviceId;
  }
  
  // 2. 없으면 UUID 생성
  deviceId = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
  
  // 3. 저장
  await AsyncStorage.setItem('device_id', deviceId);
  
  return deviceId;
}
```

**Android (Kotlin):**
```kotlin
// DeviceIdManager.kt
import android.content.Context
import android.content.SharedPreferences
import java.util.UUID

class DeviceIdManager(private val context: Context) {
    fun getOrCreateDeviceId(): String {
        val prefs = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
        var deviceId = prefs.getString("device_id", null)
        
        if (deviceId == null) {
            deviceId = UUID.randomUUID().toString()
            prefs.edit().putString("device_id", deviceId).apply()
        }
        
        return deviceId
    }
}
```

**iOS (Swift):**
```swift
// DeviceIdManager.swift
import UIKit

class DeviceIdManager {
    static func getOrCreateDeviceId() -> String {
        let defaults = UserDefaults.standard
        if let deviceId = defaults.string(forKey: "device_id") {
            return deviceId
        }
        
        let deviceId = UUID().uuidString
        defaults.set(deviceId, forKey: "device_id")
        
        return deviceId
    }
}
```

#### 2단계: API 호출 시 디바이스 ID 전달

형광펜 저장 API 호출 시 헤더에 디바이스 ID를 추가하세요:

**React Native:**
```javascript
import { getOrCreateDeviceId } from './utils/deviceId';

async function saveHighlight(highlightData) {
  const deviceId = await getOrCreateDeviceId();
  
  const response = await fetch('http://your-api.com/api/highlight/save', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-device-id': deviceId  // 👈 이렇게 추가
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
  
  return response.json();
}
```

**Android (Kotlin):**
```kotlin
val deviceId = DeviceIdManager(context).getOrCreateDeviceId()

val request = Request.Builder()
    .url("http://your-api.com/api/highlight/save")
    .addHeader("Content-Type", "application/json")
    .addHeader("x-device-id", deviceId)  // 👈 이렇게 추가
    .post(body)
    .build()
```

**iOS (Swift):**
```swift
let deviceId = DeviceIdManager.getOrCreateDeviceId()

var request = URLRequest(url: url)
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.setValue(deviceId, forHTTPHeaderField: "x-device-id")  // 👈 이렇게 추가
request.httpMethod = "POST"
request.httpBody = jsonData
```

#### 3단계: 앱 시작 시 디바이스 ID 확인

앱이 시작될 때 디바이스 ID가 생성되었는지 확인하세요:

```javascript
// App.js 또는 App.tsx
import { useEffect } from 'react';
import { getOrCreateDeviceId } from './utils/deviceId';

function App() {
  useEffect(() => {
    // 앱 시작 시 디바이스 ID 생성 (없으면 자동 생성)
    getOrCreateDeviceId().then(deviceId => {
      console.log('디바이스 ID:', deviceId);
    });
  }, []);
  
  // ... 나머지 코드
}
```

---

### 상황 2: 웹에서 테스트하거나 웹앱이라면

#### 1단계: 브라우저에서 디바이스 ID 생성

```javascript
// utils/deviceId.js
export function getOrCreateDeviceId() {
  // 1. localStorage에서 확인
  let deviceId = localStorage.getItem('device_id');
  
  if (deviceId) {
    return deviceId;
  }
  
  // 2. 없으면 UUID 생성
  deviceId = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
  
  // 3. localStorage에 저장
  localStorage.setItem('device_id', deviceId);
  
  return deviceId;
}
```

#### 2단계: API 호출 시 사용

```javascript
import { getOrCreateDeviceId } from './utils/deviceId';

async function saveHighlight() {
  const deviceId = getOrCreateDeviceId();
  
  const response = await fetch('/api/highlight/save', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-device-id': deviceId  // 👈 이렇게 추가
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
  
  return response.json();
}
```

---

### 상황 3: Postman으로 테스트만 하려면

#### 1단계: Postman Collection Import

1. Postman 열기
2. **Import** 클릭
3. `postman_highlight_api.json` 파일 선택

#### 2단계: 디바이스 ID 설정

1. 컬렉션 변수에서 `device_id` 설정
   - 값: `test-device-12345` (아무 값이나 가능)
   - 이 값이 고정되면 같은 디바이스로 인식됨

#### 3단계: 테스트

1. **1. 형광펜 추가/업데이트 (비회원)** 요청 선택
2. `x-device-id` 헤더가 자동으로 설정되어 있는지 확인
3. Body 수정 후 **Send** 클릭

---

## ✅ 체크리스트

### 앱 개발자
- [ ] 디바이스 ID 생성 함수 추가
- [ ] 로컬 저장소에 저장하는 코드 추가
- [ ] API 호출 시 `x-device-id` 헤더 추가
- [ ] 앱 시작 시 디바이스 ID 생성 확인

### 웹 개발자
- [ ] `localStorage` 기반 디바이스 ID 함수 추가
- [ ] API 호출 시 `x-device-id` 헤더 추가

### 테스트만 하는 경우
- [ ] Postman Collection Import
- [ ] `device_id` 변수 설정
- [ ] API 요청 테스트

---

## 🔍 확인 방법

### 디바이스 ID가 제대로 작동하는지 확인

1. **형광펜 저장 API 호출**
   ```bash
   POST /api/highlight/save
   Headers: x-device-id: test-device-12345
   ```

2. **형광펜 목록 조회**
   ```bash
   GET /api/highlight/list?mode=recent
   Headers: x-device-id: test-device-12345
   ```
   
3. **같은 디바이스 ID로 조회하면 저장한 형광펜이 보여야 함**

---

## ❓ 자주 묻는 질문

### Q: 디바이스 ID는 어디에 저장되나요?
- **모바일 앱**: AsyncStorage (React Native), SharedPreferences (Android), UserDefaults (iOS)
- **웹**: localStorage
- **Postman**: 컬렉션 변수

### Q: 앱을 삭제하면 디바이스 ID가 사라지나요?
- **일반적으로**: 네, 사라집니다
- **유지하려면**: Keychain (iOS) 또는 외부 저장소 (Android) 사용
- **현재 구현**: 앱 삭제 후 재설치 시 새로 생성됨 (서버에 저장된 데이터는 유지)

### Q: 회원 가입하면 어떻게 되나요?
1. 비회원으로 형광펜 사용 (디바이스 ID로 저장)
2. 회원 가입
3. 회원 가입 API에 `device_id` 포함하거나 `/api/highlight/migrate` 호출
4. 디바이스 ID의 형광펜이 회원 ID로 연동됨

---

## 📞 문제가 생기면

1. **디바이스 ID가 전달되지 않음**
   - `x-device-id` 헤더 확인
   - 브라우저 콘솔 또는 앱 로그 확인

2. **형광펜이 저장되지 않음**
   - API 응답 확인
   - 서버 로그 확인
   - 디바이스 ID 형식 확인 (문자열이어야 함)

3. **형광펜이 보이지 않음**
   - 같은 디바이스 ID로 조회하는지 확인
   - 회원인 경우 JWT 토큰 확인

---

## 🎉 완료!

이제 비회원도 형광펜 기능을 사용할 수 있습니다!

**핵심 요약:**
1. 디바이스 ID 생성 함수 만들기
2. API 호출 시 `x-device-id` 헤더 추가
3. 끝!

