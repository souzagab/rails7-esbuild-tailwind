DEVELOPMENT_PATH = .docker/dev/docker-compose.yml
PRODUCTION_PATH = .docker/prod/

## Misc
list: # List all available targets for this Makefile
	@grep '^[^#[:space:]].*:' Makefile

## Development
stop: # Stop all containers
	docker compose -f $(DEVELOPMENT_PATH) down

clean: # Stop and remove all containers, volumes and images
	docker compose -f $(DEVELOPMENT_PATH) down --rmi all --volumes --remove-orphans

build: stop # Build the containers
	docker compose -f $(DEVELOPMENT_PATH) build --no-cache
	docker compose -f $(DEVELOPMENT_PATH) run --rm app bin/setup

bash: # Open a bash session in the app container
	docker compose -f $(DEVELOPMENT_PATH) run --rm app bash

server: stop # Start the server
	docker compose -f $(DEVELOPMENT_PATH) up

## Production
IMAGE_NAME ?= "rails-app:latest"

build-release: # Build the production image
	docker build \
		--tag $(IMAGE_NAME) \
		--file "${PRODUCTION_PATH}/Dockerfile" \
		.

# TODO: Push the image to a registry
release: build-release # Build and push the production image

