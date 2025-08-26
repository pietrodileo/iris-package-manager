# Docker Guide for IRIS Package Manager

This guide provides a step-by-step explanation of the provided `docker-compose.yml` and `Dockerfile` to help you build and run a containerized InterSystems IRIS instance with your application code.

## 1. Prerequisites

Before you begin, make sure you have the following installed on your system:

* [**Docker**](https://www.docker.com/get-started "null")
* **Docker Compose** (comes with Docker Desktop)

You should also have the following files in your project directory:

* `docker-compose.yml`
* `Dockerfile`
* `entrypoint.sh`
* `iris.script`
* Your application source code in a `src/` directory.

## 2. Understanding the Docker Compose File (`docker-compose.yml`)

The `docker-compose.yml` file defines and configures the services for your application. In this case, it defines a single service named `iris`.

* **`services: iris`** : Defines a service named `iris`.
* **`build: context: .`** : Tells Docker to build the image from the local directory (`.`).
* **`dockerfile: Dockerfile`** : Specifies that the build process should use the file named `Dockerfile` in the current directory.
* **`container_name: iris-packagemanager`** : Assigns a human-readable name to the container, making it easy to reference.
* **`image: intersystems/iris-community:latest-cd`** : Specifies the base image for the container. The `latest-cd` tag indicates the latest container-ready version of InterSystems IRIS Community Edition.
* **`init: true`** : Runs an `init` process, which is useful for properly handling signals and process management inside the container.
* **`restart: unless-stopped`** : Ensures that the container will automatically restart if it crashes, but not if you manually stop it with `docker-compose down`.
* **`ports: "9092:52773"`** : Maps port `9092` on your host machine to port `52773` inside the container. This allows you to access the IRIS Management Portal and REST APIs from your browser at `http://localhost:9092`.
* **`ports: "9091:1972"`** : Maps port `9091` on your host machine to port `1972` inside the container. This is for the SuperServer, which handles connections for protocols like ODBC and JDBC.
* **`environment: - ISC_DATA_DIRECTORY=/durable/iris`** : Sets an environment variable that tells IRIS to store all its database files in the `/durable/iris` directory inside the container.
* **`volumes:`** : This is a crucial section that creates persistent storage for your application.
* **`- ./storage:/durable`** : This maps the local `./storage` directory on your host machine to the `/durable` directory inside the container. All of the IRIS database files, journals, and logs will be stored here, ensuring your data is not lost when the container is stopped or removed.
* **`- ./exports:/opt/irisapp/export`** : This maps the local `./exports` directory on your host to the `/opt/irisapp/export` directory inside the container. This is a dedicated, separate volume for the `PackageManager` to store its exported files, keeping them separate from the core database files.

## 3. Understanding the Dockerfile

The `Dockerfile` is a script that Docker uses to build the image for your application. It starts from a base image and adds your application-specific files and configurations.

* **`FROM intersystems/iris-community:latest-cd`** : Specifies the base image.
* **`USER root`** : Temporarily switches to the `root` user to perform system-level tasks.
* **`WORKDIR /opt/irisapp`** : Sets the working directory inside the container. This is where your application files will be copied.
* **`RUN chown ...`** : Changes the ownership of the working directory to the standard IRIS user (`irisowner`), ensuring that IRIS has the necessary permissions.
* **`COPY ...`** : These commands copy your local project files into the image. Your source code in `src`, the `Installer.cls`, `iris.script`, and `entrypoint.sh` are all copied into the `/opt/irisapp` directory.
* **`USER ${ISC_PACKAGE_MGRUSER}`** : Switches back from the `root` user to the `irisowner` user, as it is a security best practice to never run IRIS as `root`.
* **`About build-time imports`** : This commented section provides a critical explanation. It highlights a common problem: if you import your code during the build process (`RUN` command), it gets saved to the temporary database  *inside the image* . Because your `docker-compose.yml` uses a durable volume, that database is ignored at runtime.
* **`ENTRYPOINT ["/entrypoint.sh"]`** : Specifies the script that will be run as the primary command when the container starts. This ensures your code is always imported into the *durable* database.
* **`EXPOSE 1972 52773`** : Informs Docker that these ports will be used by the application at runtime.

## 4. Understanding the Startup Scripts (`entrypoint.sh` & `iris.script`)

These scripts work together to prepare your IRIS instance every time the container starts.

* **`entrypoint.sh`** :
* Starts IRIS in the background.
* Calls `iris session` to execute your `iris.script`, which contains the import logic.
* Once the script finishes, it hands over control to the default IRIS entry point (`/iris-main`), keeping the container running.
* **`iris.script`** :
* Uses ObjectScript commands to un-expire user passwords, which is useful for development.
* Switches to the `USER` namespace.
* Imports all the classes from the `/opt/irisapp/src` directory into the active database, which is the durable volume (`./storage`). This ensures your application code is always present.

## 5. Running the Container

With all the files in place, open your terminal or command prompt in the project's root directory and run the following command:

```
docker-compose up --build

```

* `--build` tells Docker Compose to build the image from the `Dockerfile` before starting the container. You only need to use this the first time or when you change the `Dockerfile` or any files copied into it.
* Docker will display logs from both the build process and the container startup.

Once the process completes, you can access the IRIS Management Portal in your web browser at: `http://localhost:9092/`

## 6. Stopping and Restarting

To stop the container, press `Ctrl+C` in your terminal. To stop and remove the container (but keep your persistent data in `./storage` and `./exports`), use:

```
docker-compose down

```

To run it again later without rebuilding the image, just use `docker-compose up`.

## 7. Troubleshooting

If you encounter any issues, you can check the container logs with this command to see any errors or messages from the startup scripts:

```
docker-compose logs -f

```

I hope this detailed guide helps you get your application running smoothly. Let me know if you have any questions or need to make adjustments to the guide!
