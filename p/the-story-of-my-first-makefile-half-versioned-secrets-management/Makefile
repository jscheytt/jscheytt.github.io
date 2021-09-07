# Remove default suffixes as we dont use them
.SUFFIXES:

# Set the shell to bash always
SHELL := /bin/bash

.PHONY: all
all: secrets.copy-templates

# Fetch all sample files.
secrets_samples := $(wildcard secrets/*.sample.json)
# Construct the paths for all dev secrets destinations.
dev_secrets := $(patsubst secrets/%.sample.json,secrets/dev/%.json,$(secrets_samples))
# Construct the paths for all staging secrets destinations.
staging_secrets := $(patsubst secrets/dev/%,secrets/staging/%,$(dev_secrets))
# Construct the paths for all staging secrets destinations.
prod_secrets := $(patsubst secrets/dev/%,secrets/prod/%,$(dev_secrets))
# Gather the paths of all secrets' destinations.
all_secrets := $(dev_secrets) $(staging_secrets) $(prod_secrets)

define copy_template
	cp $(1) $(2)
	@# Check if there is a more environment-specific sample file
	$(eval ENVIRONMENT := $(shell echo $(2) | sed -E 's#secrets/(.*)/.*#\1#'))
	$(eval ENVIRONMENT_SAMPLE_FILE := $(patsubst %.sample.json,%.sample.$(ENVIRONMENT).json,$(1)))
	@# If environment-specific file exists, copy it to destination
	if [ -f "$(ENVIRONMENT_SAMPLE_FILE)" ]; then cp $(ENVIRONMENT_SAMPLE_FILE) $(2); fi
endef

.PHONY: secrets.copy-templates
secrets.copy-templates: $(all_secrets)

secrets/dev/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/staging/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/prod/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)

# WARN: This is a nasty hack around Make.
# Make will copy the templates over to the target files if a template's last modified date is newer than the target file's.
# This is why we change all the file's last modified date via touch.
.PHONY: secrets.ensure-copy-once
secrets.ensure-copy-once:
	for f in $(all_secrets); do [ -f $$f ] && touch $$f; done

### Deploy the secrets to AWS SecretsManager from the corresponding secrets file
.PHONY: secret.deploy secret.deploy.config1 secret.deploy.service2 secret.deploy.service3 secrets.deploy.all secrets.deploy.dev secrets.deploy.prod
secret.deploy: $(all_secrets)
	./helpers/deploy-secret.sh $(name) < secrets/$(environment)/$(filename)
# The secret values in this one are the same across all environments
secret.deploy.config1:
	$(MAKE) secret.deploy name=envs/config1-secrets filename=config1.json
# service2 has different secret values on the different environments
secret.deploy.service2:
	$(MAKE) secret.deploy name=envs/$(environment)/service2-secrets filename=service2.json
# service 3 also has environment-specific secret values
secret.deploy.service3:
	$(MAKE) secret.deploy name=envs/$(environment)/service3-secrets filename=service3.json
# Deploy all secrets for one environment
secrets.deploy.all:
	$(MAKE) secret.deploy.config1
	$(MAKE) secret.deploy.service2
	$(MAKE) secret.deploy.service3
# Deploy all secrets for the dev cluster
secrets.deploy.dev:
	$(MAKE) secrets.deploy.all environment=dev
	$(MAKE) secrets.deploy.all environment=staging
# Deploy all secrets for the prod cluster
secrets.deploy.prod:
	$(MAKE) secrets.deploy.all environment=prod
