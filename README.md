# qwl

A stab at a personal database / application to log and keep track of workout data and whatever else I find interesting. It's also a learning experience to build and (hopefully) deploy a full-stack app with everything that entails.

## Prerequisites

* Docker and Docker Compose (V2)
* Gleam compiler (if running tests locally or working with tooling outside Docker, like Squirrel or LSP)

## Development setup

* For development you can just run `make dev-up` which should start the whole stack in dev-mode (hot reloading etc) and run migrations. 
* You can run `make dev-data-seed` to get some test/demo data to look at.
* Tests can be run from ./backend/ ./frontend/ and ./shared/ with `gleam test`.
* After adding files to the ./backend/src/sql/ directory. Run `make squirrel` to generate corresponding Gleam functions.
* `make migrate-new name=name_of_migration` for adding new migrations.
* `make pg` to spawn an interactive `psql` session inside the database container.
* `make ps` to see container status and port mappings.

## Production setup

* `make env` will create a `.env` file in the root directory where credentials can be configured.
* `make up` will build and run docker compose detached. Migrations are run with `make migrate`.

