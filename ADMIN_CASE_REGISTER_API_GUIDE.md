# 시공사례 등록 API 가이드

## 개요
관리자가 시공사례를 등록하는 API입니다. 이미지 파일과 텍스트 내용을 함께 업로드할 수 있습니다.

---

## API 정보

### 엔드포인트
```
POST /api/admin_case_register.php
```

### 인증
- **방법 1**: JWT 토큰 (권장)
  ```
  Authorization: Bearer {access_token}
  ```
- **방법 2**: 정적 API 토큰
  ```
  Authorization: Bearer intx@kys7442@1234
  ```

### 권한
- 관리자 권한 필요 (`mb_level >= 10`)

---

## 필드 매핑

| 그누보드 컬럼 | API 폼 키 | 설명 | 필수 | 기본값 |
|-------------|----------|------|------|--------|
| `wr_subject` | `title` | 제목 | ✅ | - |
| `wr_content` | `content` | 내용 (텍스트) | ✅ | - |
| `wr_seo_title` | `seo_title` | 공사명 | ✅ | - |
| `wr_option` | - | 옵션 | - | `html1` |
| `wr_name` | - | 작성자명 | - | `admin` |
| `wr_email` | - | 이메일 | - | `admin@domain.com` |
| `wr_1` | `location` | 공사현장 | ❌ | 빈 문자열 |
| `wr_2` | `company` | 시공사 | ❌ | 빈 문자열 |
| - | `category` | 카테고리 | ✅ | - |
| - | `images[]` | 이미지 파일 배열 | ✅ | - |

### 카테고리 값
- `construction`: 종합건설
- `interior`: 인테리어
- `realty`: 부동산
- `window`: 창호

---

## Postman 사용 가이드

### 1. 요청 설정

#### Method
```
POST
```

#### URL
```
https://www.int-x.co.kr/api/admin_case_register.php
```

#### Headers
```
Authorization: Bearer {access_token 또는 intx@kys7442@1234}
```

#### Body 설정
- **Type**: `form-data` 선택

#### Form Data 필드

| Key | Type | Value | 설명 |
|-----|------|-------|------|
| `category` | Text | `interior` | 카테고리 (필수) |
| `title` | Text | `테스트 시공사례` | 제목 (필수) |
| `content` | Text | `시공 내용입니다...` | 내용 (필수) |
| `seo_title` | Text | `테스트 공사명` | 공사명 (필수) |
| `location` | Text | `서울시 강남구` | 공사현장 (선택) |
| `company` | Text | `ABC 시공사` | 시공사 (선택) |
| `images[]` | File | [파일 선택] | 이미지 파일 (필수, 최소 1개) |

**참고**: `images[]`는 여러 개의 파일을 선택할 수 있습니다 (최대 20개).

### 2. Postman 스크린샷 가이드

1. **Method 선택**: POST
2. **URL 입력**: `https://www.int-x.co.kr/api/admin_case_register.php`
3. **Headers 탭**:
   - Key: `Authorization`
   - Value: `Bearer {토큰}`
4. **Body 탭**:
   - `form-data` 선택
   - 각 필드 추가:
     - `category`: Text 타입으로 `interior` 입력
     - `title`: Text 타입으로 제목 입력
     - `content`: Text 타입으로 내용 입력
     - `seo_title`: Text 타입으로 공사명 입력
     - `location`: Text 타입으로 위치 입력 (선택)
     - `company`: Text 타입으로 시공사 입력 (선택)
     - `images[]`: File 타입으로 이미지 파일 선택 (여러 개 가능)

### 3. 성공 응답 예시

```json
{
    "success": true,
    "message": "시공사례가 성공적으로 등록되었습니다",
    "data": {
        "id": 123,
        "category": "interior",
        "title": "테스트 시공사례",
        "content": "<p>시공 내용입니다...</p><p><img src=\"/data/editor/interior/2024/01/image1.jpg\" alt=\"\"></p>",
        "images": [
            "https://www.int-x.co.kr/data/editor/interior/2024/01/image1.jpg"
        ],
        "location": "서울시 강남구",
        "created_at": "2024-01-15 10:30:00"
    }
}
```

### 4. 에러 응답 예시

```json
{
    "success": false,
    "message": "입력값이 올바르지 않습니다",
    "errors": {
        "title": ["제목은 필수 항목입니다"],
        "seo_title": ["공사명은 필수 항목입니다"]
    }
}
```

---

## Flutter 앱 구현 가이드

### 1. 모델 클래스

```dart
class ConstructionCaseRequest {
  final String category;      // 'construction', 'interior', 'realty', 'window'
  final String title;          // 제목
  final String content;       // 내용 (텍스트)
  final String seoTitle;      // 공사명
  final String? location;      // 공사현장 (선택)
  final String? company;       // 시공사 (선택)
  final List<File> images;     // 이미지 파일 리스트

  ConstructionCaseRequest({
    required this.category,
    required this.title,
    required this.content,
    required this.seoTitle,
    this.location,
    this.company,
    required this.images,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'content': content,
      'seo_title': seoTitle,
      if (location != null) 'location': location,
      if (company != null) 'company': company,
    };
  }
}
```

### 2. API 서비스 클래스

```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class AdminCaseRegisterService {
  final String baseUrl = 'https://www.int-x.co.kr/api';
  final String? accessToken; // JWT 토큰 또는 정적 토큰

  AdminCaseRegisterService({this.accessToken});

  Future<Map<String, dynamic>> registerCase(
    ConstructionCaseRequest request,
  ) async {
    try {
      // MultipartRequest 생성
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin_case_register.php'),
      );

      // Headers 설정
      if (accessToken != null) {
        request.headers['Authorization'] = 'Bearer $accessToken';
      }

      // Form Data 추가
      request.fields['category'] = request.category;
      request.fields['title'] = request.title;
      request.fields['content'] = request.content;
      request.fields['seo_title'] = request.seoTitle;
      
      if (request.location != null) {
        request.fields['location'] = request.location!;
      }
      if (request.company != null) {
        request.fields['company'] = request.company!;
      }

      // 이미지 파일 추가
      for (var i = 0; i < request.images.length; i++) {
        var file = request.images[i];
        var fileName = file.path.split('/').last;
        var extension = fileName.split('.').last.toLowerCase();
        
        // MIME 타입 결정
        String mimeType;
        switch (extension) {
          case 'jpg':
          case 'jpeg':
            mimeType = 'image/jpeg';
            break;
          case 'png':
            mimeType = 'image/png';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg';
        }

        request.files.add(
          await http.MultipartFile.fromPath(
            'images[]',
            file.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );
      }

      // 요청 전송
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 응답 파싱
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return {
            'success': true,
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'message': jsonResponse['message'],
            'errors': jsonResponse['errors'],
          };
        }
      } else {
        var jsonResponse = json.decode(response.body);
        return {
          'success': false,
          'message': jsonResponse['message'] ?? '등록에 실패했습니다',
          'errors': jsonResponse['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}
```

### 3. 화면 구현 예시

```dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CaseRegisterScreen extends StatefulWidget {
  @override
  _CaseRegisterScreenState createState() => _CaseRegisterScreenState();
}

class _CaseRegisterScreenState extends State<CaseRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _seoTitleController = TextEditingController();
  final _locationController = TextEditingController();
  final _companyController = TextEditingController();
  
  String _selectedCategory = 'interior';
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final AdminCaseRegisterService _service = AdminCaseRegisterService(
    accessToken: 'YOUR_ACCESS_TOKEN', // 실제 토큰으로 교체
  );

  // 이미지 선택
  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  // 카메라로 촬영
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImages.add(File(photo.path));
      });
    }
  }

  // 등록 처리
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이미지를 최소 1개 이상 선택해주세요')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = ConstructionCaseRequest(
        category: _selectedCategory,
        title: _titleController.text,
        content: _contentController.text,
        seoTitle: _seoTitleController.text,
        location: _locationController.text.isEmpty 
            ? null 
            : _locationController.text,
        company: _companyController.text.isEmpty 
            ? null 
            : _companyController.text,
        images: _selectedImages,
      );

      var result = await _service.registerCase(request);

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('시공사례가 성공적으로 등록되었습니다')),
        );
        Navigator.pop(context, true);
      } else {
        String errorMessage = result['message'] ?? '등록에 실패했습니다';
        if (result['errors'] != null) {
          errorMessage += '\n' + result['errors'].toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('시공사례 등록'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // 카테고리 선택
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'construction', child: Text('종합건설')),
                DropdownMenuItem(value: 'interior', child: Text('인테리어')),
                DropdownMenuItem(value: 'realty', child: Text('부동산')),
                DropdownMenuItem(value: 'window', child: Text('창호')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '카테고리를 선택해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // 제목
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '제목 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // 공사명
            TextFormField(
              controller: _seoTitleController,
              decoration: InputDecoration(
                labelText: '공사명 *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '공사명을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // 내용
            TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용 *',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '내용을 입력해주세요';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // 공사현장
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: '공사현장',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 시공사
            TextFormField(
              controller: _companyController,
              decoration: InputDecoration(
                labelText: '시공사',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // 이미지 선택
            Text(
              '이미지 * (최소 1개, 최대 20개)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: Icon(Icons.photo_library),
                  label: Text('갤러리에서 선택'),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _takePhoto,
                  icon: Icon(Icons.camera_alt),
                  label: Text('카메라로 촬영'),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Image.file(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 24),

            // 등록 버튼
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _seoTitleController.dispose();
    _locationController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}
```

### 4. pubspec.yaml 의존성

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4
  http_parser: ^4.0.2
```

---

## 필드 상세 설명

### 필수 필드

1. **category** (카테고리)
   - 타입: String
   - 값: `construction`, `interior`, `realty`, `window`
   - 설명: 시공사례의 카테고리

2. **title** (제목)
   - 타입: String
   - 설명: 시공사례 제목
   - 그누보드 컬럼: `wr_subject`

3. **content** (내용)
   - 타입: String
   - 설명: 시공사례 내용 (텍스트)
   - 그누보드 컬럼: `wr_content` (HTML로 변환됨)

4. **seo_title** (공사명)
   - 타입: String
   - 설명: SEO용 공사명
   - 그누보드 컬럼: `wr_seo_title`

5. **images[]** (이미지 파일)
   - 타입: File[]
   - 설명: 이미지 파일 배열 (최소 1개, 최대 20개)
   - 지원 형식: JPEG, PNG, WebP
   - 최대 크기: 각 10MB

### 선택 필드

1. **location** (공사현장)
   - 타입: String (선택)
   - 설명: 공사 현장 위치
   - 그누보드 컬럼: `wr_1`

2. **company** (시공사)
   - 타입: String (선택)
   - 설명: 시공사 이름
   - 그누보드 컬럼: `wr_2`

---

## 에러 처리

### 일반적인 에러 코드

| HTTP 코드 | 설명 | 해결 방법 |
|----------|------|----------|
| 400 | 잘못된 요청 | 필수 필드 확인 |
| 401 | 인증 실패 | 토큰 확인 |
| 403 | 권한 없음 | 관리자 권한 확인 |
| 413 | 파일 크기 초과 | 파일 크기 확인 (10MB 이하) |
| 500 | 서버 오류 | 서버 로그 확인 |

### 에러 응답 형식

```json
{
    "success": false,
    "message": "에러 메시지",
    "errors": {
        "field_name": ["에러 메시지 배열"]
    }
}
```

---

## 주의사항

1. **이미지 처리**
   - 이미지는 자동으로 리사이징, 회전, 압축 처리됩니다
   - 최대 크기: 1920px (가로/세로 중 긴 쪽 기준)
   - 품질: 80%

2. **HTML 변환**
   - `content` 필드는 텍스트로 입력하지만, 서버에서 HTML로 변환됩니다
   - 이미지는 자동으로 `<img>` 태그로 추가됩니다
   - 줄바꿈은 `<br>` 태그로 변환됩니다

3. **기본값**
   - `wr_option`: `html1` (자동 설정)
   - `wr_name`: `admin` (자동 설정)
   - `wr_email`: `admin@domain.com` (자동 설정)

4. **토큰 관리**
   - JWT 토큰 사용 시 만료 시간 확인
   - 토큰 만료 시 `member_refresh.php`로 갱신

---

## 테스트 체크리스트

- [ ] 필수 필드만으로 등록 성공
- [ ] 모든 필드 포함하여 등록 성공
- [ ] 이미지 1개 업로드 성공
- [ ] 이미지 여러 개 업로드 성공
- [ ] 이미지 없이 등록 시도 → 에러
- [ ] 필수 필드 누락 시 에러 메시지 확인
- [ ] 잘못된 카테고리 값 → 에러
- [ ] 토큰 없이 요청 → 401 에러
- [ ] 일반 사용자 토큰 → 403 에러
- [ ] 파일 크기 초과 → 413 에러

