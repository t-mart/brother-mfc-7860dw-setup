.PHONY: up
up:
	docker compose up --detach --build --always-recreate-deps

.PHONY: down
down:
	docker compose down