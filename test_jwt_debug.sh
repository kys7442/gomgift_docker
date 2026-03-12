#!/bin/bash
# JWT 검증 디버깅 스크립트

echo "=== 1. PHP 에러 로그 확인 (최근 verify_api_token 관련) ==="
docker exec php74 tail -50 /var/log/php-fpm/error.log | grep -E "verify_api_token|require_token|JWT" | tail -20

echo -e "\n=== 2. require_token 디버깅 로그 ==="
docker exec php74 cat /tmp/require_token_debug.log 2>/dev/null | tail -10 || echo "로그 파일 없음"

echo -e "\n=== 3. member_delete 디버깅 로그 (최근) ==="
docker exec php74 cat /tmp/member_delete_debug.log 2>/dev/null | tail -3 || echo "로그 파일 없음"

echo -e "\n=== 4. API_JWT_SECRET 확인 ==="
docker exec php74 php -r "include '/var/www/html/intx/api/_common.php'; echo 'API_JWT_SECRET: ' . (defined('API_JWT_SECRET') ? substr(API_JWT_SECRET, 0, 20) . '...' : '정의되지 않음') . PHP_EOL;"

echo -e "\n=== 5. 실시간 로그 모니터링 시작 ==="
echo "다음 명령어로 실시간 로그를 확인하세요:"
echo "docker exec -it php74 tail -f /var/log/php-fpm/error.log"
echo "docker exec -it php74 tail -f /tmp/require_token_debug.log"

echo -e "\n=== 완료 ==="
