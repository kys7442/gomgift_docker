# 디바이스 고유 ID 획득 가이드

## 개요

디바이스 고유 ID는 비회원 사용자의 형광펜 데이터를 식별하기 위해 사용됩니다. 앱 설치 시 또는 첫 실행 시 생성하여 로컬 저장소에 저장하고, 이후 모든 API 호출 시 사용합니다.

---

## 플랫폼별 구현 방법

### 1. Android (Java/Kotlin)

#### 방법 1: ANDROID_ID 사용 (권장)

**장점:**
- 시스템에서 제공하는 고유 ID
- 앱 삭제 후 재설치해도 동일한 값 유지
- 별도 저장소 불필요

**단점:**
- 공장 초기화 시 변경됨
- 일부 기기에서 `null` 반환 가능

```kotlin
import android.provider.Settings
import android.content.Context
import java.util.UUID

class DeviceIdManager(private val context: Context) {
    
    fun getOrCreateDeviceId(): String {
        // 1. 로컬 저장소에서 확인
        val prefs = context.getSharedPreferences("app_prefs", Context.MODE_PRIVATE)
        var deviceId = prefs.getString("device_id", null)
        
        if (deviceId != null) {
            return deviceId
        }
        
        // 2. ANDROID_ID 시도
        deviceId = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ANDROID_ID
        )
        
        // 3. ANDROID_ID가 없거나 유효하지 않으면 UUID 생성
        if (deviceId.isNullOrEmpty() || deviceId == "9774d56d682e549c") {
            deviceId = UUID.randomUUID().toString()
        }
        
        // 4. 로컬 저장소에 저장
        prefs.edit().putString("device_id", deviceId).apply()
        
        return deviceId
    }
}
```

#### 방법 2: UUID 생성 후 저장

**장점:**
- 항상 고유한 값 보장
- ANDROID_ID가 없는 경우에도 작동

**단점:**
- 앱 삭제 후 재설치 시 새로 생성됨 (내부 저장소 사용 시 유지 가능)

```kotlin
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

---

### 2. iOS (Swift)

#### 방법 1: identifierForVendor 사용

**장점:**
- 시스템에서 제공하는 고유 ID
- 같은 벤더의 앱에서 동일한 값

**단점:**
- 앱 삭제 후 재설치 시 변경될 수 있음
- 모든 앱 삭제 후 재설치 시 변경됨

```swift
import UIKit

class DeviceIdManager {
    static func getOrCreateDeviceId() -> String {
        // 1. UserDefaults에서 확인
        let defaults = UserDefaults.standard
        if let deviceId = defaults.string(forKey: "device_id") {
            return deviceId
        }
        
        // 2. identifierForVendor 시도
        var deviceId: String
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            deviceId = vendorId
        } else {
            // 3. 없으면 UUID 생성
            deviceId = UUID().uuidString
        }
        
        // 4. UserDefaults에 저장
        defaults.set(deviceId, forKey: "device_id")
        
        return deviceId
    }
}
```

#### 방법 2: Keychain 사용 (재설치 후에도 유지)

**장점:**
- 앱 삭제 후 재설치해도 유지 가능 (Keychain 사용 시)
- 더 안전한 저장소

```swift
import Security

class DeviceIdManager {
    private static let keychainKey = "com.yourapp.device_id"
    
    static func getOrCreateDeviceId() -> String {
        // 1. Keychain에서 읽기
        if let deviceId = readFromKeychain(key: keychainKey) {
            return deviceId
        }
        
        // 2. UserDefaults에서 확인 (폴백)
        let defaults = UserDefaults.standard
        if let deviceId = defaults.string(forKey: "device_id") {
            // Keychain에도 저장
            saveToKeychain(key: keychainKey, value: deviceId)
            return deviceId
        }
        
        // 3. 새로 생성
        let deviceId: String
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            deviceId = vendorId
        } else {
            deviceId = UUID().uuidString
        }
        
        // 4. 저장
        saveToKeychain(key: keychainKey, value: deviceId)
        defaults.set(deviceId, forKey: "device_id")
        
        return deviceId
    }
    
    private static func readFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    private static func saveToKeychain(key: String, value: String) {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제 후 추가
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
}
```

---

### 3. React Native

#### react-native-device-info 라이브러리 사용

**설치:**
```bash
npm install react-native-device-info
# 또는
yarn add react-native-device-info

# iOS
cd ios && pod install
```

**구현:**
```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';

class DeviceIdManager {
  static async getOrCreateDeviceId() {
    try {
      // 1. AsyncStorage에서 확인
      let deviceId = await AsyncStorage.getItem('device_id');
      
      if (deviceId) {
        return deviceId;
      }
      
      // 2. 플랫폼별 ID 획득
      if (Platform.OS === 'android') {
        deviceId = await DeviceInfo.getAndroidId();
      } else if (Platform.OS === 'ios') {
        deviceId = DeviceInfo.getUniqueId();
      }
      
      // 3. 없으면 UUID 생성
      if (!deviceId) {
        deviceId = this.generateUUID();
      }
      
      // 4. AsyncStorage에 저장
      await AsyncStorage.setItem('device_id', deviceId);
      
      return deviceId;
    } catch (error) {
      console.error('디바이스 ID 가져오기 실패:', error);
      // 폴백: UUID 생성
      return this.generateUUID();
    }
  }
  
  static generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

// 사용 예시
const deviceId = await DeviceIdManager.getOrCreateDeviceId();
```

---

### 4. Flutter

#### device_info_plus 라이브러리 사용

**설치:**
```yaml
dependencies:
  device_info_plus: ^9.0.0
  shared_preferences: ^2.2.0
```

**구현:**
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:math';

class DeviceIdManager {
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString('device_id');
    
    if (deviceId != null) {
      return deviceId;
    }
    
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
    
    return deviceId;
  }
  
  static String _generateUUID() {
    final random = Random();
    return '${_randomHex(8)}-${_randomHex(4)}-${_randomHex(4)}-${_randomHex(4)}-${_randomHex(12)}';
  }
  
  static String _randomHex(int length) {
    final random = Random();
    return List.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16)
    ).join();
  }
}

// 사용 예시
final deviceId = await DeviceIdManager.getOrCreateDeviceId();
```

---

### 5. 웹 (PWA/웹앱)

```javascript
class DeviceIdManager {
  static getOrCreateDeviceId() {
    // 1. localStorage에서 확인
    let deviceId = localStorage.getItem('device_id');
    
    if (deviceId) {
      return deviceId;
    }
    
    // 2. UUID 생성
    deviceId = this.generateUUID();
    
    // 3. localStorage에 저장
    localStorage.setItem('device_id', deviceId);
    
    return deviceId;
  }
  
  static generateUUID() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
}

// 사용 예시
const deviceId = DeviceIdManager.getOrCreateDeviceId();
```

---

## API 호출 시 사용 방법

### React Native 예시

```javascript
import DeviceIdManager from './DeviceIdManager';

// 형광펜 저장
async function saveHighlight(highlightData) {
  const deviceId = await DeviceIdManager.getOrCreateDeviceId();
  
  const response = await fetch('http://your-api.com/api/highlight/save', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-device-id': deviceId  // 헤더로 전달
    },
    body: JSON.stringify(highlightData)
  });
  
  return response.json();
}
```

### Android (Kotlin) 예시

```kotlin
class HighlightService(private val context: Context) {
    private val deviceIdManager = DeviceIdManager(context)
    
    suspend fun saveHighlight(highlightData: HighlightData): Result<HighlightResponse> {
        val deviceId = deviceIdManager.getOrCreateDeviceId()
        
        val request = Request.Builder()
            .url("http://your-api.com/api/highlight/save")
            .addHeader("Content-Type", "application/json")
            .addHeader("x-device-id", deviceId)
            .post(highlightData.toJsonBody())
            .build()
        
        // OkHttp 등으로 요청
        return executeRequest(request)
    }
}
```

### iOS (Swift) 예시

```swift
class HighlightService {
    func saveHighlight(_ highlightData: HighlightData) async throws -> HighlightResponse {
        let deviceId = DeviceIdManager.getOrCreateDeviceId()
        
        guard let url = URL(string: "http://your-api.com/api/highlight/save") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceId, forHTTPHeaderField: "x-device-id")
        request.httpBody = try JSONEncoder().encode(highlightData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(HighlightResponse.self, from: data)
    }
}
```

---

## 주의사항

### 1. 재설치 시 데이터 유지

**Android:**
- 내부 저장소 사용 시: 앱 삭제 후 재설치 시 데이터 유지 안 됨
- 외부 저장소 사용 시: 유지 가능
- ANDROID_ID 사용 시: 공장 초기화 전까지 유지

**iOS:**
- UserDefaults 사용 시: 앱 삭제 후 재설치 시 데이터 유지 안 됨
- Keychain 사용 시: 유지 가능 (일부 제한 있음)
- identifierForVendor: 모든 앱 삭제 후 재설치 시 변경됨

### 2. 보안 고려사항

- 디바이스 ID는 개인정보가 아니지만, 사용자 추적에 사용될 수 있음
- GDPR 등 개인정보 보호 규정 준수 필요
- 필요시 사용자에게 디바이스 ID 사용 목적 안내

### 3. 테스트 시 주의사항

- 에뮬레이터/시뮬레이터에서는 고정된 값 사용 권장
- 실제 기기에서 테스트 시 다양한 시나리오 확인
- 앱 삭제 후 재설치 테스트 필수

---

## 권장 사항

1. **하이브리드 접근법 사용:**
   - 시스템 제공 ID 시도 → 없으면 UUID 생성
   - 로컬 저장소에 저장하여 재사용

2. **재설치 시 유지가 중요한 경우:**
   - Android: 외부 저장소 또는 서버 백업
   - iOS: Keychain 사용

3. **간단한 구현이 필요한 경우:**
   - UUID 생성 후 로컬 저장소에 저장
   - 앱 삭제 후 재설치 시 새로 생성되는 것은 허용

---

## 문제 해결

### Q: ANDROID_ID가 null이에요
- UUID 생성으로 폴백 처리
- 로컬 저장소에 저장하여 재사용

### Q: 앱 삭제 후 재설치 시 ID가 변경돼요
- Keychain (iOS) 또는 외부 저장소 (Android) 사용
- 또는 서버에 백업하여 복원

### Q: 여러 기기에서 동일한 ID가 생성될 수 있나요?
- UUID v4는 충돌 확률이 매우 낮음 (거의 불가능)
- 시스템 제공 ID는 기기별로 고유함

