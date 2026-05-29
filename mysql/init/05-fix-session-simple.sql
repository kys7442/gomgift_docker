-- 세션 테이블 간단 수정
USE yc_gomgift;

-- 중복 세션 제거 (가장 최근 것만 유지)
DELETE t1 FROM jgt_sessions t1
INNER JOIN jgt_sessions t2 
WHERE t1.id = t2.id 
AND t1.timestamp < t2.timestamp;

-- PRIMARY KEY 추가 시도 (이미 있으면 건너뜀 — 02/04에서 이미 처리됨)
SET @pk_exists = (
    SELECT COUNT(*)
    FROM information_schema.table_constraints
    WHERE table_schema = 'yc_gomgift'
    AND table_name = 'jgt_sessions'
    AND constraint_type = 'PRIMARY KEY'
);
SET @sql = IF(@pk_exists = 0,
    'ALTER TABLE jgt_sessions ADD PRIMARY KEY (id)',
    'SELECT "PRIMARY KEY already exists" AS message'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

