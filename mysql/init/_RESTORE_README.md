# 운영 DB → 로컬 도커(mariadb) 전체 복제 절차

작성일: 2026-05-07
대상 컨테이너: `mariadb` (mariadb:10.11, host 포트 3307→3306)

> **참고 (2026-05-29):** `06-add-ip-site.sql`, `08-add-8090-sites.sql` 은 `jgt_site`
> 테이블의 운영 스키마(`site_seq`, `site_name_eng`, `site_channelio_pluginkey`, `ins_ip` 등)를
> 전제로 하지만, 03 의 임시 정의에는 해당 컬럼이 없어 init 단계에서 `Unknown column` 으로 실패한다.
> 실제 `jgt_site` 스키마/데이터는 회사 맥 미니의 운영 DB 에만 존재하므로, 두 파일은 `.disabled` 로
> 비활성화해 init 에서 제외했다. 운영 dump 를 import 한 뒤 필요하면 다시 활성화한다.

## 1단계 — 운영 서버에서 dump 만들기

운영 서버에 SSH 접속 후 실행:

```bash
# kys7442 가 SHOW DATABASES 권한 있다고 가정. 시스템 DB 4개만 제외하고 전부 dump.
DATE=$(date +%Y%m%d_%H%M)
DUMPFILE=~/prod_alldb_${DATE}.sql

DBS=$(mysql -u kys7442 -p -N -e \
  "SELECT schema_name FROM information_schema.schemata
   WHERE schema_name NOT IN ('mysql','sys','information_schema','performance_schema');")

mysqldump -u kys7442 -p \
  --single-transaction \
  --quick \
  --no-tablespaces \
  --skip-add-locks \
  --routines --triggers --events \
  --default-character-set=utf8mb4 \
  --databases $DBS \
  > $DUMPFILE

ls -lh $DUMPFILE
```

핵심 플래그 의미:
- `--databases $DBS` : 여러 DB 한꺼번에 dump. 각 DB에 USE/CREATE DATABASE 자동 삽입.
- `--single-transaction` : InnoDB 잠금 없이 일관성 dump (운영 영향 최소).
- `--no-tablespaces` : MySQL 8 → MariaDB import 시 PROCESS 권한 부족 회피.
- `--routines --triggers --events` : 저장 프로시저 / 트리거 / 이벤트 함께 백업.
- 시스템 DB(mysql/sys/...)는 제외 → 사용자/권한 구문이 들어가지 않아 1044 원천 차단.

## 2단계 — 로컬로 가져오기

로컬 맥 터미널에서:

```bash
scp 사용자@운영서버:~/prod_alldb_YYYYMMDD_HHMM.sql \
    /Volumes/DATA/000_Projects/webdev/mysql/init/
```

## 3단계 — 도커 mariadb 에 import

```bash
DUMP=/Volumes/DATA/000_Projects/webdev/mysql/init/prod_alldb_YYYYMMDD_HHMM.sql

# 안전을 위해 dump 안에 들어있는 DB명 미리 확인
grep -E "^CREATE DATABASE|^USE \`" "$DUMP" | head

# import (root 계정 사용. dump 안에 CREATE DATABASE / USE 가 있으므로 DB 지정 불필요)
docker exec -i mariadb mysql -uroot -p"$DB_ROOT_PASSWORD" < "$DUMP"

# import 후 gomgift 사용자에게 모든 신규 DB 권한 부여 (이미 yc_gomgift 에는 있음)
docker exec mariadb mysql -uroot -p"$DB_ROOT_PASSWORD" -e "
GRANT ALL PRIVILEGES ON pamp.* TO 'gomgift'@'%';
FLUSH PRIVILEGES;
SHOW DATABASES;
"
```

## 4단계 — 로컬 .env.local 을 도커 DB 로 전환

`/Volumes/DATA/000_Projects/node/nextjs/bible_web_admin/.env.local` 변경:

```
# 도커 내부 (pamp_node 컨테이너에서)
DB_HOST=mariadb
DB_PORT=3306
DB_USER=gomgift
DB_PASSWORD=<.env의 DB_PASSWORD 값>
DB_NAME=pamp

# 호스트에서 직접 (로컬 mac 에서 npm run dev)
# DB_HOST=127.0.0.1
# DB_PORT=3307
```

## 트러블슈팅

### import 도중 1044 (Access denied)
dump 안에 GRANT/CREATE USER 줄이 들어있다는 뜻. 시스템 DB가 잘못 포함됐을 가능성:
```bash
grep -niE "^(CREATE USER|GRANT|REVOKE|DROP USER|FLUSH PRIVILEGES)" $DUMP | head
```
나오는 라인이 있으면 제거 후 재시도:
```bash
grep -viE "^(CREATE USER|GRANT|REVOKE|DROP USER|FLUSH PRIVILEGES)" $DUMP > ${DUMP%.sql}_clean.sql
docker exec -i mariadb mysql -uroot -p"$DB_ROOT_PASSWORD" < ${DUMP%.sql}_clean.sql
```

### MySQL 8 → MariaDB 호환 오류
- `utf8mb4_0900_ai_ci` 콜레이션이 MariaDB 에 없음 → sed 로 치환:
  ```bash
  sed -i '' 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g; s/CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci/CHARSET=utf8mb4/g' $DUMP
  ```
- `DEFINER=` 구문이 사용자 부재로 실패 → `--skip-definer` 또는 sed 로 제거:
  ```bash
  sed -i '' -E 's/DEFINER=`[^`]+`@`[^`]+`//g' $DUMP
  ```
