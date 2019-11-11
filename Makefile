start-concourse:
	docker-compose up -d
	while ! wget -q http://localhost:8080 -O /dev/null; do sleep 1; done;

login:
	fly -t local login --concourse-url=http://localhost:8080 --insecure --username=test --password=test

create-team:
	fly -t local set-team --team-name pay --local-user test --non-interactive

login-team:
	fly -t local-pay login --concourse-url=http://localhost:8080 --insecure --username=test --password=test -n pay

set-pipelines:
	fly -t local-pay set-pipeline \
		--pipeline provision-dev-envs \
		--config concourse/provision-dev-envs.yml \
		--var concourse-url=http://concourse:8080 \
		--var concourse-team=pay \
		--var concourse-username=test \
		--var concourse-password=test \
		--non-interactive
	fly -t local-pay unpause-pipeline -p provision-dev-envs

add-creds:
	secrets/local-ssm-add.sh /concourse/pay/cf-username paas-london/govuk-pay/org-manager-bot/username
	secrets/local-ssm-add.sh /concourse/pay/cf-password paas-london/govuk-pay/org-manager-bot/password
	secrets/local-ssm-add.sh /concourse/pay/gh-username github/readonly-user/username
	secrets/local-ssm-add.sh /concourse/pay/gh-password github/readonly-user/password

setup: start-concourse add-creds login create-team login-team set-pipelines
	
destroy:
	docker-compose down

.PHONY: setup destroy
