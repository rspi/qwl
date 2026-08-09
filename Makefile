
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
	cd backend && DATABASE_URL=postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@localhost:${DB_PORT}/${POSTGRES_DB} gleam run -m squirrel

.PHONY: migrate
migrate: .env
	docker compose run --rm dbmate up

.PHONY: rollback
rollback: .env
	docker compose run --rm dbmate down

.PHONY: migrate-new
migrate-new:
	@if [ -z "$(name)" ]; then echo "Error: 'name' is required. Example: make migrate-new name=create_tag_table"; exit 1; fi
	docker compose run --rm dbmate new $(name)

.PHONY: migrate-status
migrate-status: .env
	docker compose run --rm dbmate status

.PHONY: frontend-dev-server
frontend-dev-server:
	cd frontend && gleam run -m lustre/dev start
