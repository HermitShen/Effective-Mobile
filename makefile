-include .env
export

export PROJECT_ROOT=$(shell pwd)
export HOST_UID=$(shell id -u)
export HOST_GID=$(shell id -g)

.PHONY: env-up env-down env-cleanup env-port-forward env-port-close ps migrate-create

env-up: ## env: Запустить окружение проекта
	@docker compose up -d postgres

env-down: ## env: Остановить окружение проекта
	@docker compose down postgres

env-port-forward: ## env: Открыть порты сервисов окружения
	@docker compose up -d socat

env-port-close: ## env: Закрыть порты сервисов окружения
	@docker compose down socat

env-cleanup: ## env: Очистить окружение проекта
	@read -p "Удалить контейнеры и volume окружения? Данные PostgreSQL будут потеряны. [y/N]: " ans; \
	if [ "$$ans" = "y" ]; then \
		docker compose down -v --remove-orphans; \
		echo "Окружение очищено"; \
	else \
		echo "Очистка окружения отменена"; \
	fi

ps: ## env: Посмотреть запущенные Docker Compose сервисы
	@docker compose ps

migrate-create: ## PostgreSQL: Создать новую версию схемы данных
	@if [ -z "$(seq)" ]; then \
		echo "Отсутствует необходимый параметр seq. Пример: make migrate-create seq=init"; \
		exit 1; \
	fi; \
	docker compose run --rm migrate \
		create \
		-ext sql \
		-dir /migrations \
		-seq "$(seq)"

migrate-up: ## PostgreSQL: Накатить миграции
	@make migrate-action action=up

migrate-down: ## PostgreSQL: Откатить миграции
	@make migrate-action action=down

migrate-action:
	@if [ -z "$(action)" ]; then \
		echo "Отсутствует необходимый параметр action. Пример: make migrate-action action=up"; \
		exit 1; \
	fi; \
	docker compose run --rm migrate \
		-path /migrations \
		-database postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}?sslmode=disable \
		"$(action)"
