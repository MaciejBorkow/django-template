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
1. Copy .envs/.production `scp -r .envs/.production user@host_IP:/home/maciejb/,project_name>/.envs/'
1. Set DJANGO_ALLOWED_HOSTS in .django to server IP!!!!!!
1. Run `./compose/production/setup-server.sh` on the server
# Debugging
1) Run debug server in the python file. It opens tcp server to which ide connects.
It can be done in 2 ways:
a) Run the app with debugpy wrapper
`ENTRYPOINT ["python", "-m", "debugpy", "--listen", "0.0.0.0:5678", "manage.py", "runserver", "0.0.0.0:8000" ]`
b) Run the server inside a code and restart.
```import debugpy
debugpy.listen(("localhost", 5678))  # listen for incoming DAP client connections
debugpy.wait_for_client()```
2) Connect to the debug server from IDE by launch.json file and connect by "Run and Debug" in VScode
