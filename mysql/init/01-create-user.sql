-- 신규 유저 생성 (외부 접근 허용)
CREATE USER IF NOT EXISTS 'jgtuser'@'%' IDENTIFIED BY 'jgtcom!@#$';

-- 모든 권한 부여
GRANT ALL PRIVILEGES ON *.* TO 'jgtuser'@'%' WITH GRANT OPTION;

-- 권한 적용
FLUSH PRIVILEGES;

