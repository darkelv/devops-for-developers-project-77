# Terraform

В этой директории будут Terraform-файлы для описания облачной инфраструктуры.

Секретные значения не нужно хранить здесь в открытом виде. Они лежат в Ansible Vault:

```bash
ansible-vault view ../ansible/group_vars/all/terraform_vault.yml --vault-password-file ../.vault_password
```
