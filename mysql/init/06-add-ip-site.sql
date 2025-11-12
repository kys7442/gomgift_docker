-- IP 주소 사이트 추가
USE gomgift_net;

-- 192.168.0.24:8080 추가
INSERT INTO jgt_site (site_id, site_name, site_name_eng, site_base_url, site_channelio_pluginkey, ins_ip) 
VALUES ('jgt', '로컬 IP 포트 8080', 'Local IP port 8080', '192.168.0.24:8080', '0fc31d1d-b83c-480e-a290-0c70a9cbbdcf', '255.255.255.255')
ON DUPLICATE KEY UPDATE 
    site_name = VALUES(site_name), 
    site_name_eng = VALUES(site_name_eng);

-- 192.168.0.24 추가 (포트 없이)
INSERT INTO jgt_site (site_id, site_name, site_name_eng, site_base_url, site_channelio_pluginkey, ins_ip) 
VALUES ('jgt', '로컬 IP', 'Local IP', '192.168.0.24', '0fc31d1d-b83c-480e-a290-0c70a9cbbdcf', '255.255.255.255')
ON DUPLICATE KEY UPDATE 
    site_name = VALUES(site_name), 
    site_name_eng = VALUES(site_name_eng);

-- 확인
SELECT site_seq, site_id, site_base_url, site_name 
FROM jgt_site 
WHERE site_base_url LIKE '%192.168.0.24%'
ORDER BY site_base_url;

