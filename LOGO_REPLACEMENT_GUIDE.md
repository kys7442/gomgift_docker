# 로고 및 브랜딩 변경 가이드

## 변경 사항 요약

### 1. 브랜드명 변경
- **기존**: int-x / INT-X
- **변경**: 모두시공 / Modusigong / modusigong

### 2. 도메인 변경
- **기존**: https://int-x.co.kr
- **변경**: https://modusigong.com

### 3. 이메일 주소 변경
- **기존**: siteadmin@int-x.co.kr
- **변경**: siteadmin@modusigong.com

---

## 완료된 작업

### ✅ 텍스트 및 도메인 변경
1. **config.php**: 도메인 설정 변경
2. **theme/basic/sub/mail.php**: 이메일 주소 및 로고 URL 변경
3. **API 파일들**: 모든 API 파일의 도메인 참조 변경
   - consultation_rooms.php
   - my_construction_cases.php
   - my_inquiries.php
   - inquiry_detail.php
   - mainPageData.php
   - windowPageData.php
   - inquiryData.php
   - interiorData.php
   - realtyData.php
   - constructionData.php

---

## 로고 이미지 교체 방법

### 방법 1: Python 스크립트 사용 (권장)

1. **원본 이미지 준비**
   - 제공받은 로고 이미지를 `logo_source.png`로 저장
   - 또는 원하는 이름으로 저장

2. **스크립트 실행**
   ```bash
   cd /Volumes/DATA/000_Projects/webdev/www/intx
   python3 create_logos.py
   ```

3. **이미지 경로 입력**
   - 스크립트 실행 시 원본 이미지 경로 입력
   - 또는 `logo_source.png`를 스크립트와 같은 디렉토리에 배치

### 방법 2: 수동 교체

다음 파일들을 직접 교체하세요:

1. **테마 로고**
   - `theme/basic/img/main/logo.png` (200x60 권장)
   - `theme/basic/img/main/logo_b.png` (300x90 권장, 이메일용)

2. **기본 로고**
   - `img/logo.png` (149x36 권장)
   - `img/m_logo.png` (100x30 권장, 모바일)
   - `img/ft_logo.png` (120x35 권장, 푸터)

3. **관리자 로고**
   - `adm/img/logo.png` (150x45 권장)

---

## 로고 이미지 요구사항

### 형식
- **파일 형식**: PNG (투명 배경 지원)
- **색상 모드**: RGBA (투명도 지원)

### 크기 권장사항
- **메인 로고**: 200x60px
- **큰 로고 (이메일)**: 300x90px
- **기본 로고**: 149x36px
- **모바일 로고**: 100x30px
- **푸터 로고**: 120x35px
- **관리자 로고**: 150x45px

### 디자인 가이드라인
- 로고는 "모두시공" 또는 "Modusigong" 텍스트 포함
- 투명 배경 사용 권장
- 고해상도 원본 사용 (리사이즈 시 품질 유지)

---

## 추가 확인 사항

### 데이터베이스 설정
관리자 페이지에서 다음 설정을 확인하세요:
1. **기본환경설정 > 사이트제목**: "모두시공" 또는 "Modusigong"으로 변경
2. **기본환경설정 > 관리자 이메일**: siteadmin@modusigong.com으로 변경

### 캐시 클리어
변경 사항이 반영되지 않을 경우:
1. 브라우저 캐시 삭제
2. 서버 캐시 삭제 (있는 경우)

---

## 테스트 체크리스트

- [ ] 메인 페이지 로고 표시 확인
- [ ] 모바일 페이지 로고 표시 확인
- [ ] 푸터 로고 표시 확인
- [ ] 관리자 페이지 로고 표시 확인
- [ ] 이메일 템플릿 로고 표시 확인
- [ ] API 응답의 도메인 확인
- [ ] 사이트 제목 확인

---

## 문제 해결

### 로고가 표시되지 않는 경우
1. 파일 경로 확인
2. 파일 권한 확인 (644 권장)
3. 이미지 파일 형식 확인 (PNG)
4. 브라우저 캐시 삭제

### 도메인 관련 문제
1. `config.php`의 도메인 설정 확인
2. API 파일들의 도메인 참조 확인
3. 데이터베이스의 사이트 URL 설정 확인

---

## 문의사항

로고 교체나 브랜딩 변경 관련 문제가 있으시면 개발팀에 문의해주세요.

