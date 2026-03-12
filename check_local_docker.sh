#!/bin/bash
# 로컬 Docker 환경 디버깅 스크립트

echo "=== 1. Docker 컨테이너 상태 확인 ==="
docker ps | grep -E "nginx|php74"

echo -e "\n=== 2. Nginx 컨테이너 내부 설정 확인 ==="
docker exec nginx grep -A 5 "location ~ \.php$" /etc/nginx/conf.d/test.intx.conf | grep "HTTP_AUTHORIZATION"

echo -e "\n=== 3. Nginx 컨테이너 내부 활성 설정 확인 ==="
docker exec nginx nginx -T 2>/dev/null | grep -A 10 "test.intx.com" | grep -A 10 "location ~ \.php$" | grep "HTTP_AUTHORIZATION"

echo -e "\n=== 4. PHP 컨테이너 에러 로그 확인 ==="
docker exec php74 tail -30 /var/log/php-fpm/error.log 2>/dev/null | grep -E "member_delete|verify_api_token" || echo "로그 없음"

echo -e "\n=== 5. PHP 컨테이너 전체 에러 로그 (최근 20줄) ==="
docker exec php74 tail -20 /var/log/php-fpm/error.log 2>/dev/null

echo -e "\n=== 6. 디버깅 로그 파일 확인 ==="
docker exec php74 cat /tmp/member_delete_debug.log 2>/dev/null | tail -10 || echo "로그 파일 없음"

echo -e "\n=== 7. Nginx 액세스 로그 (최근 member_delete 요청) ==="
docker exec nginx tail -10 /var/log/nginx/test.intx.access.log | grep member_delete || echo "최근 요청 없음"

echo -e "\n=== 8. curl 테스트 (로컬에서) ==="
echo "다음 명령어로 테스트하세요:"
echo "curl -X POST http://test.intx.com/api/member_delete.php -H 'Authorization: Bearer test_token' -v"

echo -e "\n=== 완료 ==="
