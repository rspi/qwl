-- name: AddTag :one
insert into tag (name) values ($1) returning id, name;
