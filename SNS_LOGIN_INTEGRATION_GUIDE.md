# SNS 로그인 통합 가이드

## 개요
이 문서는 웹사이트와 앱에서 SNS 로그인 API를 실제로 통합하는 방법을 안내합니다.

---

## 현재 구현 상태

### ✅ 완료된 기능

1. **SNS 로그인/회원가입 API** (`/api/member_sns_login.php`)
   - Google, Naver, Kakao, Apple 지원
   - 기존 회원이면 로그인, 없으면 자동 회원가입
   - JWT 토큰 및 Refresh 토큰 발급

2. **로그아웃 API** (`/api/member_logout.php`)
   - JWT 토큰 및 Refresh 토큰 회수
   - 세션 제거

3. **토큰 갱신 API** (`/api/member_refresh.php`)
   - Access Token 만료 시 Refresh Token으로 갱신

4. **일반 로그인 API** (`/api/member_login.php`)
   - SNS 로그인 사용자 체크 기능 포함
   - SNS 로그인 사용자는 일반 로그인 불가 안내

5. **프론트엔드 라이브러리** (`/js/sns_login_api.js`)
   - SNS 로그인 API 호출 함수 제공
   - 토큰 관리 함수 포함

6. **Firebase 로그인 API** (`/api/member_firebase_login.php`)
   - Firebase Authentication ID 토큰 검증
   - providerId에 따라 `mb_sns_type` 자동 매핑

---

## 웹사이트 통합 방법

### 1. HTML에 스크립트 추가

로그인 페이지에 다음 스크립트를 추가합니다:

```html
<!-- SNS 로그인 API 클라이언트 -->
<script src="/js/sns_login_api.js"></script>

<!-- SNS SDK (각 SNS별로 추가) -->
<!-- Google -->
<script src="https://accounts.google.com/gsi/client" async defer></script>
<!-- 네이버 -->
<script src="https://static.nid.naver.com/js/naveridlogin_js_sdk_2.0.2.js"></script>
<!-- 카카오 -->
<script src="https://developers.kakao.com/sdk/js/kakao.js"></script>
```

### 2. Google 로그인 통합

```html
<div id="g_id_onload"
     data-client_id="YOUR_GOOGLE_CLIENT_ID"
     data-callback="onGoogleSignIn"
     data-auto_prompt="false">
</div>
<div class="g_id_signin"
     data-type="standard"
     data-size="large"
     data-theme="outline"
     data-text="sign_in_with"
     data-shape="rectangular"
     data-logo_alignment="left">
</div>

<script>
function onGoogleSignIn(response) {
    // Google 사용자 정보 가져오기
    google.accounts.id.initialize({
        client_id: 'YOUR_GOOGLE_CLIENT_ID'
    });
    
    google.accounts.id.prompt();
    
    // 사용자 정보 추출
    const profile = response.credential;
    const payload = JSON.parse(atob(profile.split('.')[1]));
    
    // API 호출
    googleLogin({
        getBasicProfile: function() {
            return {
                getId: () => payload.sub,
                getEmail: () => payload.email,
                getName: () => payload.name,
                getImageUrl: () => payload.picture
            };
        },
        getAuthResponse: function() {
            return {
                id_token: profile,
                access_token: '' // 필요시 추가
            };
        }
    })
    .then(function(response) {
        console.log('로그인 성공:', response.data);
        // 로그인 성공 후 처리
        window.location.href = '/';
    })
    .catch(function(error) {
        console.error('로그인 실패:', error);
        alert('로그인에 실패했습니다: ' + error.message);
    });
}
</script>
```

### 3. 네이버 로그인 통합

```html
<div id="naverIdLogin"></div>

<script>
var naverLogin = new naver.LoginWithNaverId({
    clientId: "YOUR_NAVER_CLIENT_ID",
    callbackUrl: "YOUR_CALLBACK_URL",
    isPopup: false,
    loginButton: {color: "green", type: 3, height: 58}
});

naverLogin.init();

naverLogin.getLoginStatus(function(status) {
    if (status) {
        var user = naverLogin.user;
        var accessToken = naverLogin.accessToken.accessToken;
        
        naverLogin({
            id: user.id,
            email: user.email,
            name: user.name,
            profile_image: user.profile_image
        }, accessToken)
        .then(function(response) {
            console.log('로그인 성공:', response.data);
            window.location.href = '/';
        })
        .catch(function(error) {
            console.error('로그인 실패:', error);
            alert('로그인에 실패했습니다: ' + error.message);
        });
    }
});
</script>
```

### 4. 카카오 로그인 통합

```html
<button onclick="kakaoLogin()">카카오 로그인</button>

<script>
Kakao.init('YOUR_KAKAO_APP_KEY');

function kakaoLogin() {
    Kakao.Auth.login({
        success: function(authObj) {
            Kakao.API.request({
                url: '/v2/user/me',
                success: function(res) {
                    kakaoLogin(res, authObj.access_token)
                        .then(function(response) {
                            console.log('로그인 성공:', response.data);
                            window.location.href = '/';
                        })
                        .catch(function(error) {
                            console.error('로그인 실패:', error);
                            alert('로그인에 실패했습니다: ' + error.message);
                        });
                },
                fail: function(error) {
                    console.error('카카오 사용자 정보 가져오기 실패:', error);
                }
            });
        },
        fail: function(err) {
            console.error('카카오 로그인 실패:', err);
        }
    });
}
</script>
```

### 5. Apple 로그인 통합

```html
<div id="appleid-signin" data-color="black" data-border="true" data-type="sign in"></div>

<script>
AppleID.auth.init({
    clientId: 'YOUR_APPLE_CLIENT_ID',
    scope: 'name email',
    redirectURI: 'YOUR_REDIRECT_URI',
    usePopup: true
});

document.addEventListener('AppleIDSignInOnSuccess', function(event) {
    var credential = event.detail;
    
    appleLogin(
        credential.user,
        credential.identityToken,
        credential.authorization.code
    )
    .then(function(response) {
        console.log('로그인 성공:', response.data);
        window.location.href = '/';
    })
    .catch(function(error) {
        console.error('로그인 실패:', error);
        alert('로그인에 실패했습니다: ' + error.message);
    });
});
</script>
```

### 6. Firebase Authentication (웹) 연동

Firebase SDK로 로그인한 뒤 `firebaseLogin`을 호출하면 서버와 토큰을 동기화할 수 있습니다. `FIREBASE_API_KEY` 환경변수가 서버에 설정되어 있어야 합니다.

```html
<script type="module">
import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
import { getAuth, GoogleAuthProvider, signInWithPopup } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-auth.js";

const firebaseConfig = {
  apiKey: "YOUR_FIREBASE_API_KEY",
  authDomain: "YOUR_PROJECT.firebaseapp.com",
  // ...
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const provider = new GoogleAuthProvider();

async function loginWithFirebase() {
    try {
        const result = await signInWithPopup(auth, provider);
        const user = result.user;
        const idToken = await user.getIdToken(true);

        await firebaseLogin(idToken, {
            email: user.email,
            name: user.displayName,
            photo_url: user.photoURL,
            provider: result.providerId
        });

        window.location.href = '/';
    } catch (error) {
        console.error('Firebase 로그인 실패', error);
        alert('Firebase 로그인에 실패했습니다.');
    }
}
</script>
```

---

## 모바일 앱 통합 방법

### React Native 예제

```javascript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { GoogleSignin } from '@react-native-google-signin/google-signin';
import { NaverLogin, getProfile } from '@react-native-seoul/naver-login';
import { login, getProfile as getKakaoProfile } from '@react-native-seoul/kakao-login';
import { appleAuth } from '@invertase/react-native-apple-authentication';

// API 호출 함수
async function snsLoginAPI(params) {
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
            // 토큰 저장
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

// Google 로그인
async function handleGoogleLogin() {
    try {
        await GoogleSignin.hasPlayServices();
        const userInfo = await GoogleSignin.signIn();
        const tokens = await GoogleSignin.getTokens();
        
        await snsLoginAPI({
            sns_type: 'google',
            sns_id: userInfo.user.id,
            email: userInfo.user.email,
            name: userInfo.user.name,
            photo_url: userInfo.user.photo,
            id_token: tokens.idToken,
            access_token: tokens.accessToken
        });
        
        // 로그인 성공 처리
    } catch (error) {
        console.error('Google 로그인 실패:', error);
    }
}

// 네이버 로그인
async function handleNaverLogin() {
    try {
        const result = await NaverLogin.login();
        const profile = await getProfile(result.accessToken);
        
        await snsLoginAPI({
            sns_type: 'naver',
            sns_id: profile.id,
            email: profile.email,
            name: profile.name,
            photo_url: profile.profile_image,
            access_token: result.accessToken
        });
        
        // 로그인 성공 처리
    } catch (error) {
        console.error('네이버 로그인 실패:', error);
    }
}

// 카카오 로그인
async function handleKakaoLogin() {
    try {
        const token = await login();
        const profile = await getKakaoProfile();
        
        await snsLoginAPI({
            sns_type: 'kakao',
            sns_id: String(profile.id),
            email: profile.kakao_account?.email || '',
            name: profile.kakao_account?.profile?.nickname || '',
            photo_url: profile.kakao_account?.profile?.profile_image_url || '',
            access_token: token.accessToken
        });
        
        // 로그인 성공 처리
    } catch (error) {
        console.error('카카오 로그인 실패:', error);
    }
}

// Apple 로그인
async function handleAppleLogin() {
    try {
        const appleAuthRequestResponse = await appleAuth.performRequest({
            requestedOperation: appleAuth.Operation.LOGIN,
            requestedScopes: [appleAuth.Scope.EMAIL, appleAuth.Scope.FULL_NAME],
        });
        
        if (!appleAuthRequestResponse.identityToken) {
            throw new Error('Apple Sign In failed - no identity token returned');
        }
        
        await snsLoginAPI({
            sns_type: 'apple',
            sns_id: appleAuthRequestResponse.user,
            email: appleAuthRequestResponse.email || '',
            name: appleAuthRequestResponse.fullName 
                ? `${appleAuthRequestResponse.fullName.givenName} ${appleAuthRequestResponse.fullName.familyName || ''}`.trim()
                : '',
            identity_token: appleAuthRequestResponse.identityToken,
            authorization_code: appleAuthRequestResponse.authorizationCode || ''
        });
        
        // 로그인 성공 처리
    } catch (error) {
        console.error('Apple 로그인 실패:', error);
    }
}

// Firebase Auth 로그인 후 서버 동기화
async function syncFirebaseLogin() {
    try {
        const currentUser = await firebase.auth().currentUser;
        if (!currentUser) {
            throw new Error('Firebase에 로그인된 사용자가 없습니다.');
        }

        const idToken = await currentUser.getIdToken(true);

        const response = await fetch('https://your-domain.com/api/member_firebase_login.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=utf-8'
            },
            body: JSON.stringify({
                id_token: idToken,
                email: currentUser.email,
                name: currentUser.displayName,
                photo_url: currentUser.photoURL,
                provider: currentUser.providerData && currentUser.providerData[0] ? currentUser.providerData[0].providerId : null
            })
        });

        const data = await response.json();
        if (data.success) {
            await AsyncStorage.setItem('access_token', data.data.access_token);
            if (data.data.refresh_token) {
                await AsyncStorage.setItem('refresh_token', data.data.refresh_token);
            }
            return data;
        }

        throw new Error(data.message || 'Firebase 로그인 동기화 실패');
    } catch (error) {
        console.error('Firebase 동기화 실패:', error);
        throw error;
    }
}
```

### Flutter 예제

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// API 호출 함수
Future<Map<String, dynamic>> snsLoginAPI(Map<String, dynamic> params) async {
  final response = await http.post(
    Uri.parse('https://your-domain.com/api/member_sns_login.php'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: jsonEncode(params),
  );
  
  final data = jsonDecode(response.body);
  
  if (data['success']) {
    // 토큰 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', data['data']['access_token']);
    if (data['data']['refresh_token'] != null) {
      await prefs.setString('refresh_token', data['data']['refresh_token']);
    }
    return data;
  } else {
    throw Exception(data['message'] ?? '로그인에 실패했습니다.');
  }
}

// Google 로그인 예제
Future<void> handleGoogleLogin() async {
  try {
    // Google Sign-In SDK 사용
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    
    if (account != null) {
      final GoogleSignInAuthentication auth = await account.authentication;
      
      await snsLoginAPI({
        'sns_type': 'google',
        'sns_id': account.id,
        'email': account.email,
        'name': account.displayName ?? '',
        'photo_url': account.photoUrl ?? '',
        'id_token': auth.idToken ?? '',
        'access_token': auth.accessToken ?? '',
      });
      
      // 로그인 성공 처리
    }
  } catch (error) {
    print('Google 로그인 실패: $error');
  }
}
```

> **Firebase Auth (Flutter)**  
> `firebase_auth` 패키지로 로그인한 뒤 `await user.getIdToken()` 값을 `https://your-domain.com/api/member_firebase_login.php`에 전달하면 서버 회원 정보와 동기화할 수 있습니다.

---

## 토큰 관리

### Access Token 사용

API 호출 시 Authorization 헤더에 토큰을 포함합니다:

```javascript
fetch('/api/some_endpoint.php', {
    headers: {
        'Authorization': 'Bearer ' + getAccessToken(),
        'Content-Type': 'application/json'
    }
});
```

### 토큰 갱신

```javascript
async function refreshToken() {
    const refreshToken = getRefreshToken();
    if (!refreshToken) {
        // 로그인 페이지로 이동
        window.location.href = '/login.php';
        return;
    }
    
    try {
        const response = await fetch('/api/member_refresh.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ' + getAccessToken()
            },
            body: JSON.stringify({
                refresh_token: refreshToken
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            // 새 토큰 저장
            localStorage.setItem('access_token', data.data.access_token);
            localStorage.setItem('refresh_token', data.data.refresh_token);
            return data.data.access_token;
        } else {
            throw new Error(data.message);
        }
    } catch (error) {
        // 토큰 갱신 실패 시 로그인 페이지로 이동
        snsLogout();
        window.location.href = '/login.php';
        throw error;
    }
}
```

### 로그아웃

```javascript
async function logout() {
    const accessToken = getAccessToken();
    const refreshToken = getRefreshToken();
    
    try {
        await fetch('/api/member_logout.php', {
            method: 'POST',
            headers: {
                'Authorization': 'Bearer ' + accessToken,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                refresh_token: refreshToken
            })
        });
    } catch (error) {
        console.error('로그아웃 API 호출 실패:', error);
    }
    
    // 로컬 토큰 제거
    snsLogout();
    
    // 로그인 페이지로 이동
    window.location.href = '/login.php';
}
```

---

## 주의사항

1. **보안**: 프로덕션 환경에서는 SNS 로그인 API에 `require_token()`을 활성화하는 것을 권장합니다.

2. **CORS**: API는 CORS를 허용하도록 설정되어 있지만, 필요시 특정 도메인만 허용하도록 수정할 수 있습니다.

3. **에러 처리**: 모든 API 호출에 적절한 에러 처리를 추가하세요.

4. **토큰 저장**: Access Token과 Refresh Token을 안전하게 저장하세요 (localStorage, sessionStorage, 또는 암호화된 저장소).

5. **토큰 만료**: Access Token이 만료되면 자동으로 Refresh Token을 사용하여 갱신하는 로직을 구현하세요.

6. **Firebase API 키**: `/api/member_firebase_login.php`를 사용하려면 서버 환경변수에 `FIREBASE_API_KEY`를 설정해야 하며, 클라이언트 단에 노출되는 키와는 별도로 안전하게 관리해야 합니다.

---

## 테스트 체크리스트

- [ ] Google 로그인 테스트
- [ ] 네이버 로그인 테스트
- [ ] 카카오 로그인 테스트
- [ ] Apple 로그인 테스트
- [ ] Firebase 로그인 (웹/앱) 테스트
- [ ] 신규 회원 자동 가입 테스트
- [ ] 기존 회원 로그인 테스트
- [ ] 로그아웃 테스트
- [ ] 토큰 갱신 테스트
- [ ] SNS 로그인 사용자의 일반 로그인 시도 테스트 (에러 메시지 확인)

---

## 문의사항

SNS 로그인 통합 관련 문제가 있으시면 개발팀에 문의해주세요.

