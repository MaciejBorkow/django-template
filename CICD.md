This file describes how DevOps, CICD is implemented in the project.
# Development
## Environment
1. Prefered language is Python.
2. Project is written in Django, django-ninja for API, Pydantic for business logic models.
2. Software is developed and debug using VScode.
## Software 
### VIEW
1. Income, Outcome data are represented as an Pydantic objects with suffix "In" and "Out".
2. API is developed with django-ninja and auto generate OpenAPI schema and UI from the python objects.
### CONTROLER
1. Business logic is represented by Pydantic objects.
2. All the income and outcome data are parsed to business logic objects.
3. All the business data objects are parsed to ORM objects if needed.
# MODEL
1. To keep data Django ORM and postgres is first chice. If there is any performance problem then find other solution. Otherwise alway use Django ORM and Postgres.
2. Keep Django ORM separate from business logic if possible.

# BUILD
- Project is run on Docker and docker compose.
- For development and testing docker-compose.local.yml 

# TEST
- Test are written using pytest.
- To test code run it in docker compose.
- To check linting use 'pre-commit' and ruff.

# RELEASE
- Project is build and released by GitHub actions.
- The django service image is build and release on every merge to "prod" branch on github.

# DEPLOY
- Image and repository is pulled on production server using 'update-image.sh'

# MONITOR
- TODO - grafana