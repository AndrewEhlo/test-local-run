# 🚀 Try Virtocommerce solution locally

Run Virtocommerce backend, Virtocommerce frontend, database server, Redis, Elasticsearch and Kibana on your local machine using a simple powershell script. This setup uses [Docker](https://www.docker.com/) behind the scenes to install and run the services.

> [!IMPORTANT]  
> This script is for local testing only. Do not use it in production!
> !TODO! For production installations refer to the official documentation for [Elasticsearch](https://www.elastic.co/downloads/elasticsearch) and [Kibana](https://www.elastic.co/downloads/kibana).

## 🌟 Options

- The script allows to choose **MSSQL** or **PostgreSQL**
- The solution can be installed as a **backend only** or **backend + frontend** combination

## 💻 System requirements

- ~5 GB of available disk space
- [Git client](https://git-scm.com/downloads/guis)
- [Docker](https://www.docker.com/)
- Works on Windows
- !TODO! On Linux and MacOS it works using pwsh [Install PowerShell on Linux](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux), [Installing PowerShell on macOS](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos)

## 🏃‍♀️‍➡️ Getting started

### Setup

Clone the `!TODO!` repository using any Git client:

```pwsh
git clone https://!TODO!
```

This repository contains all necessary files to run a VirtoCommerce solution locally:

- `docker-compose*.yml`: Docker Compose configurations for VirtoCommerce solution
- `backend` folder: Dockerfile for the backend component
- `frontend` folder: Dockerfile for the frontend component
- `scripts` folder: Scripts used by the main script
- `VirtoLocal.ps1`: Script to start and stop a VirtoCommerce solution

### Select the versions to install

The components' versions are controlled by the script parameters:
- `postgresVersion`: PostgresSQL version
- `mssqlVersion`: MsSQL version
- `elasticsearchVersion`: Version for the Elastic Stack
- `vcModulesBundle`: [VirtoCommerce module bundle version](https://github.com/VirtoCommerce/vc-modules/tree/master/bundles)
- `frontendRelease`: Version for the [VirtoCommerce frontend](https://github.com/VirtoCommerce/vc-frontend/releases)

As an example of using:

```pwsh
.\VirtoLocal.ps1 -command 'start' -vcModulesBundle 'v11'
```

The previous command installs Elasticsearch and Kibana `8.16.0`.

Using the `-v` parameter, you can also install beta releases, this can be useful for testing an
upcoming release. For instance, you can install the `9.0.0-beta1` using the following
command:

```bash
curl -fsSL https://elastic.co/start-local | sh -s -- -v 9.0.0-beta1
```

The `9.0.0-beta1` version was released on February 18, 2025.

### Install only Elasticsearch

If you want to install only Elasticsearch, without Kibana, you can use the `--esonly` option
as follows:

```bash
curl -fsSL https://elastic.co/start-local | sh -s -- --esonly
```

This command can be useful if you don't have enough resources and want to test only Elasticsearch.

### 🌐 Endpoints

After running the script:

- Elasticsearch will be running at <http://localhost:9200>
- Kibana will be running at <http://localhost:5601>

The script generates a random password for the `elastic` user, displayed at the end of the installation and stored in the `.env` file.

> [!CAUTION]
> HTTPS is disabled, and Basic authentication is used for Elasticsearch. This configuration is for local testing only. For security, Elasticsearch and Kibana are accessible only via `localhost`.

### 🔑 API key

An API key for Elasticsearch is generated and stored in the `.env` file as `ES_LOCAL_API_KEY`. Use this key to connect to Elasticsearch with the [Elastic SDK](https://www.elastic.co/guide/en/elasticsearch/client) or [REST API](https://www.elastic.co/guide/en/elasticsearch/reference/current/rest-apis.html).

Check the connection to Elasticsearch using `curl` in the `elastic-start-local` folder:

```bash
source .env
curl $ES_LOCAL_URL -H "Authorization: ApiKey ${ES_LOCAL_API_KEY}"
```

## 🐳 Start and stop the services

You can use the `start` and `stop` commands available in the `elastic-start-local` folder.

To **stop** the Elasticsearch and Kibana Docker services, use the `stop` command:

```bash
cd elastic-start-local
./stop.sh
```

To **start** the Elasticsearch and Kibana Docker services, use the `start` command:

```bash
cd elastic-start-local
./start.sh
```

[Docker Compose](https://docs.docker.com/reference/cli/docker/compose/).

## 🗑️ Uninstallation

To remove the `start-local` installation:

```bash
cd elastic-start-local
./uninstall.sh
```

> [!WARNING]  
> This erases all data permanently.

## 📝 Logging

If the installation fails, an error log is created in `error-start-local.log`. This file contains logs from Elasticsearch and Kibana, captured using the [docker logs](https://docs.docker.com/reference/cli/docker/container/logs/) command.

## ⚙️ Customizing settings

To change settings (e.g., Elasticsearch password), edit the `.env` file. Example contents:

```bash
ES_LOCAL_VERSION=8.15.2
ES_LOCAL_URL=http://localhost:9200
ES_LOCAL_CONTAINER_NAME=es-local-dev
ES_LOCAL_DOCKER_NETWORK=elastic-net
ES_LOCAL_PASSWORD=hOalVFrN
ES_LOCAL_PORT=9200
KIBANA_LOCAL_CONTAINER_NAME=kibana-local-dev
KIBANA_LOCAL_PORT=5601
KIBANA_LOCAL_PASSWORD=YJFbhLJL
ES_LOCAL_API_KEY=df34grtk...==
```

> [!IMPORTANT]
> After changing the `.env` file, restart the services using `stop` and `start`:
>
> ```bash
> cd elastic-start-local
> ./stop.sh
> ./start.sh
> ```

## ⚠️ Advanced settings with ENV variables

We offer some environment (ENV) variables for changing the settings of `start-local`.
We suggest to use these ENV variables only for advanced use cases, e.g. CI/CD integrations.
Please use caution when using these settings.

### ES_LOCAL_PASSWORD

If you need to set the Elasticsearch password manually, you can do it using the `ES_LOCAL_PASSWORD`.

You need to set the env variable before the execution of the script, as follows:

```bash
curl -fsSL https://elastic.co/start-local | ES_LOCAL_PASSWORD="supersecret" sh
```

This command will set the `supersecret` password for Elasticsearch.

**Please note** that this command can be dangerous if you use a weak password
for Elasticsearch authentication.

### ES_LOCAL_DIR

By default, start-local creates an `elastic-start-local` folder. If you need to change it, you can use
the `ES_LOCAL_DIR` env variable, as follows:

```bash
curl -fsSL https://elastic.co/start-local | ES_LOCAL_DIR="another-folder" sh
```

This command will creates the `another-folder` containing all the start-local files.

## 🧪 Testing the installer

We use [bashunit](https://bashunit.typeddevs.com/) to test the script. Tests are in the `/tests` folder.

### Running tests

1. Install bashunit:

   ```bash
   curl -s https://bashunit.typeddevs.com/install.sh | bash
   ```

2. Run tests:

   ```bash
   lib/bashunit
   ```

The tests run `start-local.sh` and check if Elasticsearch and Kibana are working.

> [!NOTE]
> For URL pipeline testing, a local web server is used. This requires [PHP](https://www.php.net/).