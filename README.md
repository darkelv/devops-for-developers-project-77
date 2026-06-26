### Hexlet tests and linter status:
[![Actions Status](https://github.com/darkelv/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/darkelv/devops-for-developers-project-77/actions)

# DevOps for Developers Project 77

Учебный проект для подготовки инфраструктуры в DigitalOcean.

## Что создается

Terraform создает:

- 2 виртуальные машины для веб-серверов
- Load Balancer, который принимает HTTPS-запросы на порт `443`
- Managed PostgreSQL для приложения
- firewall для доступа к веб-серверам
- файл `ansible/inventory.ini` для Ansible

Ansible разворачивает на веб-серверах:

- Docker
- Redmine container
- `.env` файл с подключением к Managed PostgreSQL

HTTPS сделан через self-signed сертификат. Для учебной проверки этого достаточно, но браузер будет показывать предупреждение о сертификате.

## Секреты

Токен DigitalOcean хранится в Ansible Vault:

```bash
ansible/group_vars/all/terraform_vault.yml
```

Секрет Redmine хранится отдельно:

```bash
ansible/group_vars/all/vault.yml
```

Посмотреть файл можно так:

```bash
make vault_view
```

Перед запуском Terraform Makefile создает локальный файл:

```bash
terraform/secret.auto.tfvars
```

Этот файл не нужно коммитить, он добавлен в `.gitignore`.

После создания инфраструктуры Makefile может создать локальные Ansible-переменные из Terraform outputs:

```bash
ansible/group_vars/all/terraform_outputs.yml
```

Там будет пароль базы, поэтому этот файл тоже добавлен в `.gitignore`.

Если нужен SSH-доступ к виртуальным машинам для Ansible, добавьте fingerprint уже существующего SSH-ключа DigitalOcean в локальный файл:

```bash
terraform/local.auto.tfvars
```

Пример:

```hcl
ssh_key_fingerprints = ["aa:bb:cc:dd:..."]
```

## Команды

Установить Ansible-зависимости:

```bash
make install_requirements
```

Инициализация Terraform:

```bash
make init
```

Форматирование Terraform-файлов:

```bash
make fmt
```

Проверка конфигурации:

```bash
make validate
```

Показать план создания инфраструктуры:

```bash
make plan
```

Создать инфраструктуру:

```bash
make infra
```

Проверить синтаксис Ansible playbook:

```bash
make ansible_check
```

Сгенерировать Ansible-переменные из Terraform outputs:

```bash
make ansible_vars
```

Подготовить веб-серверы:

```bash
make prepare
```

Развернуть Redmine:

```bash
make deploy
```

Показать outputs:

```bash
make output
```

Удалить инфраструктуру:

```bash
make destroy
```

Удалить локальный файл с секретами Terraform:

```bash
make clean
```

Обычный порядок запуска:

```bash
make infra
make deploy
```

После проверки:

```bash
make destroy
make clean
```
