This is a [Next.js](https://nextjs.org) project bootstrapped with [`create-next-app`](https://nextjs.org/docs/pages/api-reference/create-next-app).

## Getting Started

First, run the development server:

```bash
npm run dev
# or
yarn dev
# or
pnpm dev
# or
bun dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `pages/index.tsx`. The page auto-updates as you edit the file.

[API routes](https://nextjs.org/docs/pages/building-your-application/routing/api-routes) can be accessed on [http://localhost:3000/api/hello](http://localhost:3000/api/hello). This endpoint can be edited in `pages/api/hello.ts`.

The `pages/api` directory is mapped to `/api/*`. Files in this directory are treated as [API routes](https://nextjs.org/docs/pages/building-your-application/routing/api-routes) instead of React pages.

This project uses [`next/font`](https://nextjs.org/docs/pages/building-your-application/optimizing/fonts) to automatically optimize and load [Geist](https://vercel.com/font), a new font family for Vercel.

## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn-pages-router) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/pages/building-your-application/deploying) for more details.


##Version

- 1.0.0


##install

```
node v22.10.0
npm v10.9.0
```

## Bible Highlights API

모바일 앱과의 동기화를 위해 다음 REST 엔드포인트가 추가되었습니다.

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/bible/highlights` | 하이라이트 저장 |
| GET | `/api/bible/highlights` | 하이라이트 목록 조회 (필터/페이지네이션 지원) |
| PUT | `/api/bible/highlights/:id` | 하이라이트 수정 |
| DELETE | `/api/bible/highlights/:id` | 하이라이트 삭제(소프트) |
| POST | `/api/bible/highlights/sync` | 단말 ↔ 서버 간 하이라이트 동기화 |

### 공통 요구 사항
- `Authorization: Bearer {JWT}` 헤더와 `x-request-source: app` 헤더가 반드시 포함돼야 합니다.
- JWT는 `/api/login`에서 발급되며, 세션 검증을 통과해야 합니다.
- 요청/응답 형식은 `application/json`입니다.

### 예시 (저장)
```bash
curl -X POST https://www.pamp.co.kr/api/bible/highlights \
  -H "Authorization: Bearer <TOKEN>" \
  -H "x-request-source: app" \
  -H "Content-Type: application/json" \
  -d '{
    "book_id": 1,
    "chapter_id": 1,
    "verse_number": "1",
    "start_position": 0,
    "end_position": 10,
    "selected_text": "태초에 하나님이",
    "style": "highlight",
    "color": "yellow"
  }'
```
