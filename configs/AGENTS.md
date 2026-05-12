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

# Architecture boundaries and rules
- Do not introduce new architectural layers, service patterns, or storage choices unless the repo already establishes them or the change requires them.

 -Use Pydantic models for request and response schemas. Where a module already follows the convention, use `In` and `Out` suffixes.

- Keep API transport concerns, business logic, and persistence concerns separate.
- Keep business logic separate from Django ORM models where practical.
- Parse request data into business objects before persistence-specific work.
- Convert business objects into ORM objects only where database interaction is required.
- Use Django ORM and Postgres as the default persistence path. Do not introduce an alternative persistence pattern without a demonstrated need.
- Do not leak ORM objects directly into API schemas unless the existing module already does so intentionally.

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
- Run `uv run pre-commit run` to check linters.

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
