# Ansible

В этой директории лежат Ansible-плейбуки и переменные для настройки серверов.

Файл `group_vars/all/terraform_vault.yml` хранит зашифрованные переменные, которые нужны Terraform для работы с облаком.

После создания инфраструктуры Terraform сгенерирует файл `inventory.ini` с адресами веб-серверов.

Основной playbook:

```bash
playbook.yml
```

Он устанавливает Docker и запускает Redmine container на веб-серверах.
Также он устанавливает Datadog Agent и настраивает `http_check` для локальной проверки Redmine на `http://localhost:3000/`.

Локальный файл `group_vars/all/terraform_outputs.yml` создается командой `make ansible_vars` и не коммитится, потому что содержит пароль Managed PostgreSQL.
