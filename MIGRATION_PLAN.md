# 그누보드5 → Next.js 마이그레이션 계획

## 프로젝트 개요
- **원본 사이트**: modusigong.com (그누보드5)
- **대상 프레임워크**: Next.js 15 (TypeScript, App Router)
- **목표**: 주요 기능만 마이그레이션, UI/UX 그대로 유지

## 마이그레이션 범위

### ✅ 포함할 기능
1. **관리자 페이지**
   - 회원 관리 (목록, 검색, 수정, 삭제)
   - 게시판 관리 (생성, 수정, 삭제)
   - 기본 설정 (일부 - 사이트 제목, 관리자 이메일 등)

2. **사용자 페이지**
   - 게시판 목록/보기/쓰기/수정/삭제
   - 댓글 기능
   - 파일 업로드/다운로드
   - 회원가입/로그인/로그아웃
   - 최신글 표시

3. **UI/UX**
   - 기존 테마(basic)의 모든 HTML/CSS/JS 복제
   - 관리자 페이지 스타일 그대로 유지

### ❌ 제외할 기능
- 쇼핑몰 기능
- SMS 관리
- 포인트 시스템 (필요시 추후 추가)
- 기타 확장 기능들

## 데이터베이스 구조

### 주요 테이블
- `g5_member` - 회원 정보
- `g5_board` - 게시판 설정
- `g5_write_{bo_table}` - 게시글 (동적 테이블)
- `g5_config` - 사이트 설정
- `g5_group` - 게시판 그룹
- `g5_board_file` - 첨부파일

## 프로젝트 구조

```
intx-nextjs/
├── app/
│   ├── admin/
│   │   ├── members/
│   │   ├── boards/
│   │   └── settings/
│   ├── bbs/
│   │   ├── board/
│   │   │   └── [bo_table]/
│   │   │       ├── page.tsx (목록)
│   │   │       ├── [wr_id]/
│   │   │       │   └── page.tsx (보기)
│   │   │       └── write/
│   │   │           └── page.tsx (쓰기)
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── register/
│   │   │   └── page.tsx
│   │   └── ...
│   └── page.tsx (메인)
├── components/
│   ├── admin/
│   ├── board/
│   └── common/
├── lib/
│   ├── db.ts (데이터베이스 연결)
│   ├── auth.ts (인증)
│   └── gnuboard.ts (그누보드 호환 함수)
├── public/
│   ├── theme/
│   │   └── basic/ (기존 CSS/JS/이미지 복사)
│   └── adm/ (관리자 CSS/JS/이미지)
└── types/
```

## 개발 단계

### Phase 1: 프로젝트 설정 ✅
- [x] Next.js 프로젝트 생성
- [ ] 데이터베이스 연결 설정
- [ ] 인증 시스템 기본 구조
- [ ] 기존 CSS/JS/이미지 복사

### Phase 2: 공통 기능
- [ ] 레이아웃 컴포넌트 (head, tail)
- [ ] 인증 시스템 (로그인/로그아웃)
- [ ] 그누보드 호환 함수 라이브러리

### Phase 3: 사용자 페이지
- [ ] 메인 페이지 (최신글)
- [ ] 게시판 목록
- [ ] 게시판 보기
- [ ] 게시판 쓰기/수정
- [ ] 댓글 기능

### Phase 4: 관리자 페이지
- [ ] 회원 관리
- [ ] 게시판 관리
- [ ] 기본 설정

### Phase 5: UI 복제
- [ ] 테마 스킨 복제
- [ ] 관리자 스타일 복제
- [ ] 반응형 처리

## 기술 스택
- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Database**: MySQL (기존 DB 사용)
- **ORM**: mysql2 직접 사용 (그누보드 호환성)
- **Authentication**: 커스텀 세션 (그누보드 호환)
- **Styling**: 기존 CSS 그대로 사용 + Tailwind (선택적)

## 주의사항
1. 기존 데이터베이스 구조 유지 (그누보드5 호환)
2. 기존 파일 업로드 경로 유지 (`/data/` 폴더)
3. 세션/쿠키 방식 호환성 고려
4. 기존 URL 구조 최대한 유지 (`/bbs/board.php?bo_table=xxx` → `/bbs/board/xxx`)

