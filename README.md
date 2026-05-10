Setup django project with one command based on latest [django-cookiecutter](https://github.com/cookiecutter/cookiecutter-django)

# Local development
Requires:
- postgres libs `sudo apt-get install -y libpq-dev postgresql-client`
- docker
- uv
- justfile
# Setup project
Run `init-repo.sh <project_name>`
# Server run
1. Install postgres libs, docker, uv, just.
1. Authorize github and `gh` command.
1. Add Github docker registry.
1. Pull repo from Github 'gh repo clone MaciejBorkow/<repo_name>'
1. Run `./compose/production/setup-server.sh` on the server