Launch containers
=================

```
docker compose up -d postgres ldap consul consul-seed ssh

docker compose build && docker compose up rundeck
```

Default passwords for local docker compose
==========================================

* Static rundeck users:
* admin:pass
* bot:bot

* from LDAP:
* Services
* svc:svcpwd
* rundeck:rundeckpwd

* Users:
* userexec:userexecpwd

Create password
===============

```
java -jar rundeck.war --encryptpwd Jetty
```

Misc commands
=============

```
make run_standalone update_defaults kill_standalone
```

Docker build and push
=====================

```
docker buildx build --push --platform=linux/amd64,linux/arm64 -t nledez/rundeck:4.7.0 .
```

Use with rundeck-cli
====================

```
export RD_URL="http://127.0.0.1:4440/"
export RD_USER="admin"
export RD_PASSWORD="pass"
```

Import examples
===============

```
rd projects create --project=MyProject --file=tests/rundeck/rundeck-MyProject/files/etc/project.properties
rd jobs load --format=yaml --project=MyProject --file=tests/rundeck/rundeck-MyProject/jobs/Local_hostname.yaml 
rd jobs load --format=yaml --project=MyProject --file=tests/rundeck/rundeck-MyProject/jobs/Ssh_hostname.yaml
```
