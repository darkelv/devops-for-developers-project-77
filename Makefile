VAULT_PASSWORD_FILE ?= .vault_password
TERRAFORM_DIR = terraform
ANSIBLE_DIR = ansible
VAULT_FILE = ansible/group_vars/all/terraform_vault.yml
APP_VAULT_FILE = ansible/group_vars/all/vault.yml
TFVARS_FILE = $(TERRAFORM_DIR)/secret.auto.tfvars
ANSIBLE_INVENTORY = $(ANSIBLE_DIR)/inventory.ini
ANSIBLE_OUTPUT_VARS = $(ANSIBLE_DIR)/group_vars/all/terraform_outputs.yml
TERRAFORM = terraform -chdir=$(TERRAFORM_DIR)
PLAYBOOK = ansible-playbook --vault-password-file $(VAULT_PASSWORD_FILE) -i $(ANSIBLE_INVENTORY)

.PHONY: tfvars init fmt validate plan infra destroy output install_requirements ansible_check ansible_vars prepare deploy clean vault_view vault_app_view

tfvars:
	ansible-vault view $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE) \
		| sed -n 's/^\([A-Za-z0-9_]*\):[[:space:]]*\(.*\)$$/\1 = \2/p' > $(TFVARS_FILE)
	chmod 600 $(TFVARS_FILE)

init: tfvars
	$(TERRAFORM) init

fmt:
	$(TERRAFORM) fmt

validate: init
	$(TERRAFORM) validate

plan: init
	$(TERRAFORM) plan

infra: init
	$(TERRAFORM) apply -auto-approve

destroy: init
	$(TERRAFORM) destroy -auto-approve

output:
	$(TERRAFORM) output

install_requirements:
	ansible-galaxy collection install -r $(ANSIBLE_DIR)/requirements.yml

ansible_check: install_requirements
	@tmp_inventory=$$(mktemp); \
	printf '%s\n' '[webservers]' 'localhost ansible_connection=local' > $$tmp_inventory; \
	ansible-playbook --vault-password-file $(VAULT_PASSWORD_FILE) -i $$tmp_inventory $(ANSIBLE_DIR)/playbook.yml --syntax-check; \
	rm -f $$tmp_inventory

ansible_vars:
	@test -f $(ANSIBLE_INVENTORY) || (echo "Run make infra first"; exit 1)
	@$(TERRAFORM) output -json | jq -r '[ \
		"---", \
		("redmine_db_host: " + (.database_host.value | @json)), \
		("redmine_db_port: " + (.database_port.value | tostring)), \
		("redmine_db_name: " + (.database_name.value | @json)), \
		("redmine_db_user: " + (.database_user.value | @json)), \
		("redmine_db_password: " + (.database_password.value | @json)) \
	] | .[]' > $(ANSIBLE_OUTPUT_VARS)
	chmod 600 $(ANSIBLE_OUTPUT_VARS)

prepare: install_requirements
	$(PLAYBOOK) $(ANSIBLE_DIR)/playbook.yml --tags prepare

deploy: install_requirements ansible_vars
	$(PLAYBOOK) $(ANSIBLE_DIR)/playbook.yml --tags prepare,deploy

clean:
	rm -f $(TFVARS_FILE) $(ANSIBLE_OUTPUT_VARS)

vault_view:
	ansible-vault view $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)

vault_app_view:
	ansible-vault view $(APP_VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)
