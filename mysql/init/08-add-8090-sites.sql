USE gomgift_net;

-- test.cp_gomgift.net:8090 추가
INSERT INTO jgt_site (site_id, site_name, site_name_eng, site_base_url, site_channelio_pluginkey, ins_ip)
VALUES ('jgt', '로컬 CP 사이트 포트 8090', 'Local CP Site port 8090', 'test.cp_gomgift.net:8090', '0fc31d1d-b83c-480e-a290-0c70a9cbbdcf', '255.255.255.255')
ON DUPLICATE KEY UPDATE
    site_name = VALUES(site_name),
    site_name_eng = VALUES(site_name_eng);

-- test.cp_gomgift.net 추가 (포트 없이)
INSERT INTO jgt_site (site_id, site_name, site_name_eng, site_base_url, site_channelio_pluginkey, ins_ip)
VALUES ('jgt', '로컬 CP 사이트', 'Local CP Site', 'test.cp_gomgift.net', '0fc31d1d-b83c-480e-a290-0c70a9cbbdcf', '255.255.255.255')
ON DUPLICATE KEY UPDATE
    site_name = VALUES(site_name),
    site_name_eng = VALUES(site_name_eng);

-- 192.168.0.24:8090 추가
INSERT INTO jgt_site (site_id, site_name, site_name_eng, site_base_url, site_channelio_pluginkey, ins_ip)
VALUES ('jgt', '로컬 IP 포트 8090', 'Local IP port 8090', '192.168.0.24:8090', '0fc31d1d-b83c-480e-a290-0c70a9cbbdcf', '255.255.255.255')
ON DUPLICATE KEY UPDATE
    site_name = VALUES(site_name),
    site_name_eng = VALUES(site_name_eng);

