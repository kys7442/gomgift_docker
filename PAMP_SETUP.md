# Pamp 사이트 추가 (로컬 테스트 및 도커 배포)

아래 내용은 `www/pamp` 폴더와 `nginx/conf.d/pamp.conf`가 이미 레포에 추가되어 있다고 가정합니다.

1) 로컬 macOS에서 테스트

- `/etc/hosts` 파일에 다음을 추가하세요 (관리자 권한 필요):

```
127.0.0.1 test.pamp.com
```

- 도커 컨테이너 시작/재시작:

```bash
# 백그라운드로 실행
docker-compose up -d

# nginx 설정 변경 시 재시작
docker-compose restart nginx
```

- 브라우저에서 확인: http://test.pamp.com

2) 도커를 통한 실서버 배포(옵션)

- DNS에서 `pamp.co.kr` 도메인을 서버 IP로 포인팅하세요.
- `nginx/conf.d/pamp.conf`의 `server_name` 항목에 실도메인을 추가하거나 교체하세요.
- HTTPS를 적용하려면 인증서(예: Let's Encrypt)를 추가로 설정하세요.

3) 설정 참고

- 웹 루트: `www/pamp` (컨테이너 내부: `/var/www/html/pamp`)
- PHP-FPM: 기본은 `php82:9000`로 설정되어 있습니다. 필요 시 `php74:9000`으로 변경하세요.

5) 실제 프로젝트 경로 반영 — 당신의 경우

- 실제 Next.js 프로젝트 경로: `/Volumes/D/000/webdev/w/p/bible_web_admin`입니다. 도커 설정은 이 경로를 컨테이너의 작업 디렉터리(`/usr/src/app`)로 마운트하도록 구성되어 있습니다.

6) 컨테이너 내부에서 `npm install` 실행 및 에러 수집 방법

1) 호스트의 `node_modules`가 있다면 삭제하세요 (충돌 방지):

```bash
rm -rf /Volumes/D/000/webdev/w/p/bible_web_admin/node_modules
```

2) 컨테이너를 올리고(이미 올린 경우 재시작):

```bash
docker-compose up -d pamp_node nginx
```

3) 컨테이너 내부에서 설치 시도 (실제 오류 로그를 보려면 아래 중 하나 수행):

```bash
# 1) 컨테이너에 접속해서 수동으로 설치
docker-compose exec pamp_node sh
# 컨테이너 쉘에서
npm install

# 2) 또는 한 번만 실행하고 로그를 확인
docker-compose run --rm pamp_node sh -c "npm install"
```

4) 설치 중 에러가 나면 전체 로그(오류 스택)를 복사해서 붙여주세요. 빠르게 원인을 진단해 드립니다.

7) 권장 추가 설정/팁

- `.dockerignore` (프로젝트 루트에 생성) 예시 — 호스트의 불필요한 파일을 컨테이너에 복사하지 않게 합니다:

```
node_modules
.next
npm-debug.log
dist
```

- Alpine 이미지를 사용할 때 네이티브 모듈 빌드가 필요하면 추가 패키지가 필요합니다. 예: `build-base python3 g++ make` 등.
	- 임시로 컨테이너에서 `apk add --no-cache build-base python3` 등을 실행해서 빌드해 보세요.

- 권한 문제 발생 시 (EACCES): 컨테이너 내부에서 `chown -R node:node /usr/src/app` 후 non-root `node` 사용자로 `npm install` 수행을 권장합니다.


5) Next.js / Node 설정 안내 (중요)

- 본 레포에서 `pamp` 사이트는 PHP가 아니라 Node(Next.js)로 동작해야 합니다. 위에 추가한 Docker 설정은 `pamp_node` 서비스로 Node 컨테이너를 만들어 `3000` 포트로 구동하고, Nginx가 이 컨테이너로 리버스 프록시합니다.

- 기본 흐름 (개발):
	1. `www/pamp`에 `package.json`과 Next.js 소스가 있어야 합니다.
	2. 도커로 빌드/실행: `docker-compose up -d --build pamp_node nginx`
	3. 브라우저에서 `http://test.pamp.com` 접속 → Nginx가 `pamp_node:3000`으로 프록시합니다.

- `npm install` 에러 관련 (자주 발생하는 원인과 해결책):
	- 원인: 호스트에서 `npm install`을 실행해 `node_modules`를 생성하고, 같은 디렉터리를 컨테이너에 마운트하면 플랫폼(예: macOS vs Linux) 차이로 바이너리 네이티브 모듈이 문제를 일으킵니다.
		해결: 컨테이너 내부에서 설치하거나, 도커 컨테이너의 `node_modules`를 별도 named volume으로 보관하세요. (이미 `docker-compose.yml`에 `pamp_node_node_modules` named volume 추가됨)
	- 원인: `package.json` 또는 `package-lock.json`이 누락되었거나 잘못된 경로에서 실행한 경우
		해결: `www/pamp`에 `package.json`이 있는지 확인하세요.
	- 권한 문제(EACCES): 볼륨 마운트로 인해 파일 권한이 맞지 않을 수 있습니다.
		해결: 컨테이너 안에서 `chown -R node:node /usr/src/app` 또는 `npm`을 루트가 아닌 적절한 유저로 실행하세요.
	- Node 버전 불일치: 로컬에서 빌드된 네이티브 모듈이 컨테이너의 Node ABI와 다를 수 있습니다.
		해결: 도커파일에서 사용하는 Node 버전(`node:18-alpine`)을 로컬 dev 환경과 맞추거나, 컨테이너 내부에서 `npm ci`로 설치하세요.

- 빠른 해결 절차 (권장):
	1. `www/pamp`에 `package.json`이 있는지 확인.
	2. 호스트에서 이미 `node_modules`가 존재하면 제거:

```bash
rm -rf www/pamp/node_modules
```

	3. 컨테이너에서 설치/실행 (빌드 포함):

```bash
docker-compose build pamp_node
docker-compose up -d pamp_node nginx
docker-compose logs -f pamp_node
```

	4. 설치 중 에러가 나면 `docker-compose logs pamp_node` 또는 `docker-compose run --rm pamp_node sh -c "npm install"` 명령으로 에러 출력 확인.

문제가 계속되면 `npm install` 실패 시 출력된 오류(전체 로그)를 붙여주세요. 오류 로그를 보면 원인(권한, 네트워크, 바이너리 컴파일 실패 등)을 명확히 판단하고 구체적으로 수정해 드리겠습니다.

4) 문제 해결 팁

- 도메인이 연결되지 않으면 `/etc/hosts` 또는 DNS 설정을 확인하세요.
- Nginx 로그 확인:

```bash
docker-compose logs nginx
tail -n 200 nginx/pamp-error.log
```
