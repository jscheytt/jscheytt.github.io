# Remove default suffixes as we dont use them
# How Not To Shoot Yourself in the Foot
.SUFFIXES:

# Set the shell to bash always
SHELL := /bin/bash

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
	[ -f $(ENVIRONMENT_SAMPLE_FILE) ] && cp $(ENVIRONMENT_SAMPLE_FILE) $(2)
endef

.PHONY: secrets.copy-templates
secrets.copy-templates: $(all_secrets)

secrets/dev/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/staging/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/prod/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets.copy-templates: $(all_secrets)

# WARN: This is a nasty hack around Make.
# Make will copy the templates over to the target files if a template's last modified date is newer than the target file's.
# This is why we change all the file's last modified date via touch.
secrets.ensure-copy-once:
	for f in $(all_secrets); do [ -f $$f ] && touch $$f; done

### Deploy the secrets to AWS SecretsManager from the corresponding secrets file
secret.deploy: $(all_secrets)
	./helpers/deploy-secret.sh $(name) < secrets/$(environment)/$(filename)
secret.deploy.akamai:
	make secret.deploy name=envs/akamai-edgerc filename=akamai-edgerc.json
secret.deploy.backend:
	make secret.deploy name=envs/$(environment)/dcpc-mrktplc-de-secrets filename=backend.json
secret.deploy.odus-sync:
	make secret.deploy name=envs/dcpm-odus-sync-config-secrets filename=odus-sync.json
secret.deploy.solr:
	make secret.deploy name=envs/solrCredentials filename=solr.json
	make secret.deploy name=envs/solrOperatorCredentials filename=solr-operator.json
secret.deploy.teams:
	make secret.deploy name=envs/msteams-deploy-hook-address filename=teams-webhook.json
secret.deploy.vds-sync:
	make secret.deploy name=envs/dcpm-vds-sync-config-secrets filename=vds-sync.json
secrets.deploy.all:
	make secret.deploy.akamai
	make secret.deploy.backend
	make secret.deploy.odus-sync
	make secret.deploy.solr
	make secret.deploy.teams
	make secret.deploy.vds-sync
secrets.deploy.dev:
	make secrets.deploy.all environment=dev
	make secrets.deploy.all environment=int
	make secrets.deploy.all environment=preprod
secrets.deploy.prod:
	make secrets.deploy.all environment=prod

### Get public IP addresses of all nodes in a cluster
.PHONY: ips.dev ips.prod
ip-addresses-%.txt:
	./helpers/get-ip-addresses.sh | sort | uniq > $@
ips.dev: ip-addresses-dev.txt
ips.prod: ip-addresses-prod.txt

.PHONY: all git-hooks secrets.copy-templates secrets.create.solr secret.deploy secret.deploy.akamai secret.deploy.backend secret.deploy.odus-sync secret.deploy.solr secret.deploy.teams secret6.deploy.vds-sync secrets.deploy.all secrets.deploy.dev secrets.deploy.prod ips.dev ips.prod
