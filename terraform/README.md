# Terraform

В этой директории лежат Terraform-файлы для облачной инфраструктуры.

Terraform создает:

- 2 виртуальные машины для веб-приложения
- HTTPS Load Balancer
- Managed PostgreSQL
- домен `opsinfrapath.ru`
- DNS A-record на Load Balancer
- firewall для веб-серверов
- `ansible/inventory.ini`

HTTPS использует уже существующий сертификат DigitalOcean с именем `opsinfrapath.ru`.

Секреты не хранятся здесь в открытом виде. Команда `make tfvars` создает локальный файл `secret.auto.tfvars` из Ansible Vault.
