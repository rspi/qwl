
CREATE_ENV = cp .env.template .env

.PHONY: up
up: .env
	docker compose up

.env: .env.template
	$(CREATE_ENV)

.PHONY: env
env:
	$(CREATE_ENV)
