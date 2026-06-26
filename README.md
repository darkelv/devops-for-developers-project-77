### Hexlet tests and linter status:
[![Actions Status](https://github.com/darkelv/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/darkelv/devops-for-developers-project-77/actions)

# DevOps for Developers Project 77

Учебный проект для подготовки инфраструктуры в DigitalOcean.

## Что создается

Terraform создает:

- 2 виртуальные машины для веб-серверов
- Load Balancer, который принимает HTTPS-запросы на порт `443`
- Managed PostgreSQL для приложения
- домен `opsinfrapath.ru`
- DNS A-record, который указывает на Load Balancer
- firewall для доступа к веб-серверам
- файл `ansible/inventory.ini` для Ansible

Ansible разворачивает на веб-серверах:

- Docker
- Redmine container
- `.env` файл с подключением к Managed PostgreSQL
- Datadog Agent
- Datadog `http_check`, который проверяет `http://localhost:3000/` на каждом веб-сервере

Terraform также создает Datadog alert:

- monitor `Redmine HTTP check`
- проверка идет по service check `http.can_connect`
- alert группируется по `host`, поэтому каждый веб-сервер проверяется отдельно

HTTPS работает через уже существующий сертификат DigitalOcean с именем `opsinfrapath.ru`.
Домен у регистратора должен быть направлен на nameserver-ы DigitalOcean.

Приложение после деплоя будет доступно по адресу:

```text
https://opsinfrapath.ru
```

## Требования

Перед запуском нужны:

- Terraform
- Ansible
- Ansible Vault
- `jq`
- доступ к DigitalOcean
- доступ к Datadog
- домен `opsinfrapath.ru`, направленный на nameserver-ы DigitalOcean
- существующий сертификат DigitalOcean с именем `opsinfrapath.ru`

В корне проекта должен быть файл с паролем от Ansible Vault:

```bash
.vault_password
```

Этот файл не коммитится.

## Секреты

Токен DigitalOcean хранится в Ansible Vault:

```bash
ansible/group_vars/all/terraform_vault.yml
```

Там же лежат переменные для Terraform Datadog provider:

```yaml
datadog_api_key: "..."
datadog_app_key: "..."
```

`datadog_app_key` нужно заменить на реальный Datadog application key:

```bash
make vault_edit
```

Секрет Redmine хранится отдельно:

```bash
ansible/group_vars/all/vault.yml
```

В этом же файле лежит `vault_datadog_api_key`, который использует Ansible для установки Datadog Agent.

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

Установить или обновить Datadog Agent отдельно:

```bash
make datadog
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
