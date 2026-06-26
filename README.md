### Hexlet tests and linter status:
[![Actions Status](https://github.com/darkelv/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/darkelv/devops-for-developers-project-77/actions)

# DevOps for Developers Project 77

Учебный проект по Terraform и Ansible.

Terraform поднимает инфраструктуру в DigitalOcean, а Ansible ставит Docker,
запускает Redmine и подключает Datadog Agent.

Приложение доступно тут:

```text
https://opsinfrapath.ru
```

## Что используется

- DigitalOcean Droplets
- DigitalOcean Load Balancer
- Managed PostgreSQL
- DNS-запись для домена
- Redmine в Docker
- Datadog `http_check` и monitor

## Перед запуском

Нужны Terraform, Ansible, `jq`, доступы к DigitalOcean и Datadog.

Пароль от Ansible Vault лежит локально в файле:

```bash
.vault_password
```

Секреты лежат в vault-файлах:

```bash
ansible/group_vars/all/terraform_vault.yml
ansible/group_vars/all/vault.yml
```

Локальные файлы с секретами и Terraform outputs не коммитятся.

## Основные команды

```bash
make install_requirements
make init
make validate
make ansible_check
make infra
make deploy
```

После проверки инфраструктуру можно удалить:

```bash
make destroy
make clean
```

Если нужен SSH-доступ к серверам, fingerprint ключа добавляется локально в:

```bash
terraform/local.auto.tfvars
```
