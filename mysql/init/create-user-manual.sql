-- 수동 실행용: 이미 데이터베이스가 초기화된 경우 사용
-- 실행 방법: docker exec -i mariadb mysql -uroot -pdudtlr00 < create-user-manual.sql

-- 신규 유저 생성 (외부 접근 허용)
CREATE USER IF NOT EXISTS 'jgtuser'@'%' IDENTIFIED BY 'jgtcom!@#$';

-- 모든 권한 부여
GRANT ALL PRIVILEGES ON *.* TO 'jgtuser'@'%' WITH GRANT OPTION;

-- 권한 적용
FLUSH PRIVILEGES;

