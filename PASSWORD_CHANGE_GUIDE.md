# 비밀번호 변경 가이드

## ⚠️ 보안 주의사항

이 파일은 **임시로만 사용**하고, 사용 후 **반드시 삭제**하세요!

---

## 사용 방법

### 방법 1: Postman 사용

1. **URL**: `http://test.pamp.com/api/admin/change-password` (또는 운영 서버 주소)
2. **Method**: `POST`
3. **Headers**: 
   ```
   Content-Type: application/json
   ```
4. **Body** (JSON):
   ```json
   {
     "username": "변경할사용자명",
     "new_password": "새비밀번호"
   }
   ```

**예시**:
```json
{
  "username": "admin",
  "new_password": "newpassword123"
}
```

### 방법 2: curl 명령어

```bash
curl -X POST http://test.pamp.com/api/admin/change-password \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "new_password": "newpassword123"
  }'
```

### 방법 3: 브라우저 콘솔 (개발 환경)

브라우저 개발자 도구 콘솔에서:

```javascript
fetch('/api/admin/change-password', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    username: 'admin',
    new_password: 'newpassword123'
  })
})
.then(res => res.json())
.then(data => console.log(data))
.catch(err => console.error(err));
```

---

## 응답 예시

**성공 시**:
```json
{
  "success": true,
  "message": "사용자 'admin'의 비밀번호가 성공적으로 변경되었습니다.",
  "user_id": 1
}
```

**실패 시**:
```json
{
  "error": "사용자 'admin'를 찾을 수 없습니다."
}
```

---

## 사용 후 조치

1. 비밀번호 변경 완료 후 **즉시 이 파일을 삭제**하세요.
2. 또는 파일 이름을 변경하여 비활성화하세요 (예: `change-password.js.disabled`)

---

## 직접 SQL 쿼리 (비추천)

bcrypt로 암호화되어 있어서 직접 SQL로는 불가능합니다. 
하지만 이미 해싱된 비밀번호를 알고 있다면:

```sql
UPDATE members 
SET password = '이미_해싱된_비밀번호_문자열' 
WHERE username = '사용자명';
```

**주의**: 이 방법은 보안상 매우 위험하므로 권장하지 않습니다.

