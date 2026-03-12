#!/bin/bash
# PHP 로그 파일 위치 찾기

echo "=== 1. PHP-FPM 설정 파일에서 에러 로그 위치 확인 ==="
docker exec php74 grep -E "error_log|php_admin_value\[error_log\]" /etc/php-fpm.d/www.conf 2>/dev/null | head -5
docker exec php74 grep -E "error_log|php_admin_value\[error_log\]" /etc/php-fpm.conf 2>/dev/null | head -5

echo -e "\n=== 2. PHP 설정에서 error_log 확인 ==="
docker exec php74 php -i 2>/dev/null | grep -E "error_log|log_errors" | head -5

echo -e "\n=== 3. /var/log 디렉토리 확인 ==="
docker exec php74 ls -la /var/log/ 2>/dev/null | head -10

echo -e "\n=== 4. /tmp 디렉토리 확인 ==="
docker exec php74 ls -la /tmp/ | grep -E "member_delete|require_token" || echo "디버깅 로그 파일 없음"

echo -e "\n=== 5. PHP-FPM 프로세스 확인 ==="
docker exec php74 ps aux | grep php-fpm | head -3

echo -e "\n=== 6. 직접 테스트 요청 보내기 ==="
echo "다음 명령어로 테스트하세요:"
echo "curl -X POST http://test.intx.com/api/member_delete.php -H 'Authorization: Bearer test_token' -v"

echo -e "\n=== 완료 ==="
