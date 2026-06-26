VAULT_PASSWORD_FILE ?= .vault_password
TERRAFORM_DIR = terraform
VAULT_FILE = ansible/group_vars/all/terraform_vault.yml
TFVARS_FILE = $(TERRAFORM_DIR)/secret.auto.tfvars
TERRAFORM = terraform -chdir=$(TERRAFORM_DIR)

.PHONY: tfvars init fmt validate plan infra destroy output clean vault_view

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

clean:
	rm -f $(TFVARS_FILE)

vault_view:
	ansible-vault view $(VAULT_FILE) --vault-password-file $(VAULT_PASSWORD_FILE)
