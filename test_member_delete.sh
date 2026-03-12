#!/bin/bash
# 회원탈퇴 API 직접 테스트

echo "=== 회원탈퇴 API 테스트 ==="
echo ""
echo "실제 JWT 토큰을 사용하려면 아래 명령어를 수정하세요:"
echo ""

# 테스트 토큰 (실제 토큰으로 교체 필요)
TEST_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJtYl9pZCI6Im1hc3RlcjEiLCJtYl9uYW1lIjoiXHVjNTkxXHViMmU0XHVjODE1IiwibWJfZW1haWwiOiJkYWplb25nMUBvcGVuY29tLmNvbSIsIm1iX2xldmVsIjoyLCJtYl9yb2xlIjoidXNlciIsImlhdCI6MTc2OTA0ODc2NywiZXhwIjoxNzY5MDUyMzY3LCJqdGkiOiJlZGM5NDJmZDUyYTM3MTVmNmMyNzU0OGIyOTVmMTk5YSJ9.0NYWMhV06wvzduvgmm8af80ThamV-phFQhu29V0YAFk"

echo "curl 테스트 실행 중..."
echo ""

curl -X POST http://test.intx.com/api/member_delete.php \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TEST_TOKEN" \
  -v 2>&1 | tee /tmp/curl_response.log

echo ""
echo ""
echo "=== 응답 분석 ==="
echo "응답에 'debug' 필드가 포함되어 있으면 JWT 검증 실패 원인을 확인할 수 있습니다."
echo ""
echo "응답 로그: /tmp/curl_response.log"
