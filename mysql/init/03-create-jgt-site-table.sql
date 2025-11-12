-- jgt_site 테이블 생성
CREATE TABLE IF NOT EXISTS `jgt_site` (
  `site_id` int(11) NOT NULL AUTO_INCREMENT,
  `site_base_url` varchar(255) NOT NULL,
  `site_name` varchar(255) DEFAULT NULL,
  `site_status` varchar(20) DEFAULT 'active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`site_id`),
  KEY `idx_site_base_url` (`site_base_url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- 기본 사이트 데이터 삽입
INSERT INTO `jgt_site` (`site_base_url`, `site_name`, `site_status`) 
VALUES 
  ('test.gomgift.net', 'gomgift.net 테스트 사이트', 'active'),
  ('test.gomgift.net:8080', 'gomgift.net 포트 8080', 'active'),
  ('192.168.0.24', '로컬 IP 사이트', 'active'),
  ('192.168.0.24:8080', '로컬 IP 포트 8080', 'active')
ON DUPLICATE KEY UPDATE `site_name` = VALUES(`site_name`);

