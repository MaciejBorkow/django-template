This file is the repository instruction entrypoint for coding agents. Use it as the default workflow contract for changes in this repo.

# System environment and tooling.
- OS: Ubuntu
- Runtime: Docker compose, docker, Ubuntu
- Database: Postgres
- Queues: Celery, redis
- Primary Programming language: Python 3.14
- Core Frameworks: Django, django-ninja, Pydantic, celery, pytest
- Python packeges manager: uv
- CICD: Github workflows
- Image registry: Github image registry
- Python and packages version are in `pyproject.toml`

# Python software architecture boundaries and rules
- Use Clean Architecture pattern in the following form: Entity -> Use Case -> Interface -> Data Source.
- Entity is pydantic Class representing fundamental domain object.
- Use Case is an operation on Entity representing essential operations from domain point of view. It uses Interfaces to external data sources. Accept only Entity and basic python data types and custom pydantic class used in Entities.
- Interface is wrapper around data sources as Django ORM, external API, django-ninja API etc returning only datatypes essential for Entity or Entitiy.
- Data Source is for example Postgres database, redis, external API.
- Always write separate pydatnic class for django-ninja API  input with suffix "In" and output data with "Out" if required and translate to Entity or Django ORM if needed. Do not use Django ORM API view ModelSchema. 
- If domain logic require long SQL query with many parameters, just make a method in DjangoORM interface and do it there without forwarding many parameters. Otherwise keep domain logic in Use Case layer.
- Convert business objects into ORM objects only where database interaction is required.
- Use Django ORM and Postgres as the default persistence path. Do not introduce an alternative persistence pattern without a demonstrated need.

# Validation Contract
- After changing Python behavior, run the narrowest relevant test first.
- Before finishing a non-trivial change, run the smallest useful validation set for the files you touched.

# Instructions
## Build local development environment instructions
- File `docker-compose.local.yml` describs local development infrastructure and services.
- Environmental variables are read from `.envs/.local/.django` and `.envs/.local/.postgres`.
- Use `uv` inside docker compose service `django` to install python packages, run python code.
- Use `just build` to build the project.
- Use `just up` to run the project.

## Debugging instructions
- Use `just logs <service_name>` to check logs.
- Use `just run <command>` to run one time command inside django service.
- Use `just manage <command>` to run django command inside django service.

## Test instructions
- Pytest config and linters config is in the `pyproject.toml`
- Run `just test [pytest args]` to test.
- Run `just type [path]` to check typing.
- Run `just ruff` to check and fix Python linting and code formatting.
- Run `just pre-commit` to check linters.

## Commit
- Make sure you are not on the `prod` branch. If you are on the `prod` branch, make a new branch with a meaningfull name for a task and add all changes there.
- Make a commit only when all test instructions are passed.

## Pull reques
- Create pull request when all task requirements are met.
- Pull request has to be from task branch to `prod` branch.
 
 # Release And Deploy
- GitHub Actions builds and pushes the production Django image on commit to the `prod` branch.
- Build details live in `.github/workflows/docker-image.yml` and `compose/production/django/Dockerfile`.
- The published image format is `ghcr.io/<owner>/<repo>_django:<tag>`.
- The image tag is derived from the source branch name after Docker-safe sanitization.
- Production deploy operations are script-based under `compose/production/`, including `setup-server.sh` and `update-image.sh`.

# Access Restrictions
Do NOT read, index, or modify the following paths:
- `logs/` (Application logs)
- Any file matching `*.sqlite3` or `*.log`
