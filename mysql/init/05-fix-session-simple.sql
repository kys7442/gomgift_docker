-- 세션 테이블 간단 수정
USE gomgift_net;

-- 중복 세션 제거 (가장 최근 것만 유지)
DELETE t1 FROM jgt_sessions t1
INNER JOIN jgt_sessions t2 
WHERE t1.id = t2.id 
AND t1.timestamp < t2.timestamp;

-- PRIMARY KEY 추가 시도 (이미 있으면 에러 무시)
ALTER TABLE jgt_sessions ADD PRIMARY KEY (id);

