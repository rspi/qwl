
# Load environment variables from .env file, if it exists.
ifneq ($(wildcard .env),)
include .env
export
endif

CREATE_ENV = cp .env.template .env

.PHONY: up
up: .env
	docker compose up

.PHONY: upd
upd: .env
	docker compose up --detach

.PHONY: down
down:
	docker compose down

.PHONY: pg
pg: .env
	docker compose exec db psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

.PHONY: ps
ps:
	docker compose ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"

.env: .env.template
	$(CREATE_ENV)

.PHONY: env
env:
	$(CREATE_ENV)

.PHONY: squirrel
squirrel: .env
	cd backend && DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:5432/${POSTGRES_DB} gleam run -m squirrel
