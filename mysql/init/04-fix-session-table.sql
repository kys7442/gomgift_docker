-- 세션 테이블 수정 스크립트
-- 중복 세션 데이터 정리 및 PRIMARY KEY 추가

USE gomgift_net;

-- 1. 중복 세션 데이터 정리 (가장 최근 것만 유지)
DELETE t1 FROM jgt_sessions t1
INNER JOIN (
    SELECT id, MAX(timestamp) as max_timestamp
    FROM jgt_sessions
    GROUP BY id
    HAVING COUNT(*) > 1
) t2 ON t1.id = t2.id
WHERE t1.timestamp < t2.max_timestamp;

-- 2. PRIMARY KEY가 없으면 추가
SET @pk_exists = (
    SELECT COUNT(*)
    FROM information_schema.table_constraints
    WHERE table_schema = 'gomgift_net'
    AND table_name = 'jgt_sessions'
    AND constraint_type = 'PRIMARY KEY'
);

SET @sql = IF(@pk_exists = 0,
    'ALTER TABLE jgt_sessions ADD PRIMARY KEY (id)',
    'SELECT "PRIMARY KEY already exists" as message'
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 3. 인덱스 확인 및 추가
SET @idx_exists = (
    SELECT COUNT(*)
    FROM information_schema.statistics
    WHERE table_schema = 'gomgift_net'
    AND table_name = 'jgt_sessions'
    AND index_name = 'jgt_sessions_timestamp'
);

SET @sql2 = IF(@idx_exists = 0,
    'CREATE INDEX jgt_sessions_timestamp ON jgt_sessions(timestamp)',
    'SELECT "Index already exists" as message'
);

PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- 4. 오래된 세션 정리 (12시간 이상 지난 세션)
DELETE FROM jgt_sessions 
WHERE timestamp < UNIX_TIMESTAMP(DATE_SUB(NOW(), INTERVAL 12 HOUR));

