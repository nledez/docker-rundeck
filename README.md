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
