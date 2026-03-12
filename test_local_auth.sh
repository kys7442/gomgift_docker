#!/bin/bash
# 로컬 Docker 환경 인증 테스트 스크립트

echo "=== 1. Nginx 설정 테스트 ==="
docker exec nginx nginx -t

echo -e "\n=== 2. Nginx 재로드 ==="
docker exec nginx nginx -s reload

echo -e "\n=== 3. Nginx 활성 설정 확인 ==="
docker exec nginx nginx -T 2>/dev/null | grep -A 10 "test.intx.com" | grep -A 10 "location ~ \.php$" | grep "HTTP_AUTHORIZATION"

echo -e "\n=== 4. PHP 에러 로그 확인 (최근 20줄) ==="
docker exec php74 tail -20 /var/log/php-fpm/error.log 2>/dev/null

echo -e "\n=== 5. 디버깅 로그 파일 확인 ==="
docker exec php74 cat /tmp/member_delete_debug.log 2>/dev/null | tail -5 || echo "로그 파일 없음"

echo -e "\n=== 6. curl 테스트 ==="
echo "다음 명령어로 테스트하세요:"
echo "curl -X POST http://test.intx.com/api/member_delete.php -H 'Authorization: Bearer test_token' -v"

echo -e "\n=== 완료 ==="
echo "이제 앱에서 회원탈퇴를 시도하고, 아래 명령어로 실시간 로그를 확인하세요:"
echo "docker exec -it php74 tail -f /var/log/php-fpm/error.log"
