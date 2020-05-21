# Unifolv-API

## Prerequisites
- Python 3.6 (Ignore if using Docker)
- Virtualenv (Ignore if using Docker)
- Postgres 9.6 + (Ignore if using Docker)
- Docker (Optional)
- Docker Compose (Optional)

## Installation

```bash
# 1. Clone source code
- CD to project folder

# 2. Copy ./compose/.envs/.example ./compose/.envs/.local
$ cp -r ./compose/.envs/.example ./compose/.envs/.local

# 3. Edit env files in ./compose/.envs/.local if necessary (ex: POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, ...)

# 4. Copy .env.example to ./config/settings/.env
$ cp .env.example ./config/settings/.env


# 5. Edit DATABASE_URL in ./config/settings/.env
DATABASE_URL=postgres://goldfish:123456@postgres:5432/goldfish
```


## Using Virtualenv
```bash
# 1. Create and activate virtualenv
$ python3 -m venv virtualenv
$ source ./virtualenv/bin/activate

# 2. Install dependencies
$ pip install -r requirements/local.txt

# 3. Migrate database
$ ./manage.py migrate

# 4. Start Django
$ ./manage.py runserver 0.0.0.0:8000
```

## Build and Start App using Docker
```bash
# Build
$ docker-compose -f dev.yml build

# Start container
$ docker-compose -d dev.yml up -d

# Stop container
$ docker-compose -f dev.yml down
```

## Create super user
```bash
# 1. SSH to docker container
$ docker exec template_api_django bash
$ ./manage.py createsuperuser

# 2. Enter email, username, password
```

## Django Admin
- URL: http://localhost:8000/admin

## Swagger Document
- URL: http://localhost:8000/docs

## API Authentication
- Both OAuth2 and Auth Token are supported

## Create OAuth2 Application
- Login to Django Admin
- Click Application to create new application
    + Choose an User
    + Client type: public
    + Authorization Grant type: Resource owner password-based
    + Enter application name
    + Save

## Oauth2 API
- URL: http://localhost:8000/v1/o/token/
- Method: POST
- Example

<img src="./docs/images/oauth2.png">


## Create new App

```bash
# 1. SSH to API Container
$ docker exec -ti <CONTAINER ID|NAME> bash

# 2. Create new app folder
$ mkdir -p app/[APP_NAME]

# 3. Create new app
$ ./manage.py startapp [APP_NAME] app/[APP_NAME]

# 4. Update your app name in app config in app/[APP_NAME]/apps.py

name = 'app.[APP_NAME]'


# 5. Add new app in config/settings/common
LOCAL_APPS = (
    'app.core.apps.CoreConfig',
    'app.users.apps.UserConfig',
    'app.APP_NAME',
)

```
## Best Practices
- separate into multiple small apps
- Avoid cycle dependency
- Should use UUID for Primary Key

Example

```python
user_id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
```

## Setup Production Environment
```
npm run terraform:deploy:production
```

## Environment Terraform Setup
Terraform is used to setup the cloud environment. We use AWS (Amazon Web Services) to house the environment. There are a number of terraform related scripts that can be found within the `package.json` file. Each script is titled to reflect the service and environment. For example `npm run terraform:vpc:init:production` with initialize the production AWS `vpc`. Please review the `package.json` file to familiarize yourself with the other services.

Make sure you have your AWS credentials handy. I suggest either setting your global AWS credentials or exporting the following environment variables before proceeding.
```
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="secretkey"
export AWS_DEFAULT_REGION="eu-west-2"
```

Review the /hosting/terraform/example.backend.json and /hosting/terraform/example.json files for configuration variables. In order to update production, you must have a respective environment file. For example, you would have a production.json an production.backend.json file. Please contact your administrator for production values.

Follow the below steps to create the environemnt:
```npm run terraform:deploy:production```

