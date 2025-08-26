* ```bash
  docker-compose up -d
  ```

http://localhost:9092/csp/sys/UtilHome.csp

Password1234

docker compose down -v

🔹 `docker-compose up -d --build`

* **Cosa fa** : ricostruisce l’immagine *se necessario* e subito dopo avvia il container.
* **Quando builda** : ricostruisce solo se rileva cambiamenti nel Dockerfile o nei file copiati (ma usa la cache di Docker).

oppure

🔹 `docker-compose build --no-cache iris`

* **Cosa fa** : forza la ricostruzione dell’immagine del servizio `iris`, **senza cache** (quindi ogni `COPY`, `RUN`, ecc. viene rieseguito da zero).
* **Quando builda** : sempre, anche se non è cambiato nulla.

After this, when container is running, you should activate client side mode from vscode.

To do that:

- Create a namespace connection to the IRIS container through settings.json
- Click on: View -> Command Palette -> ObjectScript: Connect Folder to Server Namespace... -> Select the container namespace
- Start working on files into the local src/ folder. Any change will be reflected to the container as well since now the folder base are synchronised and the local src folder has become the source of truth.
- This can be used with git source control as well. Just create a repository and do git init into the main project local folder, then connect it to the repo. Any local change will be synch both with git and iris container.

Si deve creare una cartella .vscode per il client side editing, contenente un settings.json così fatto:

{

    "objectscript.conn": {

    "server": "docker_pkg_manager",

    "ns": "USER",

    "active": true

    }

}

---

---

---

# IRIS Package Manager: User and Deployment Guide

The IRIS Package Manager is a web-based application designed to streamline the management and export of code assets within an InterSystems IRIS environment. It features a modern, dynamic user interface built to simplify common development tasks.

## Key Features and Functionality

The application offers a user-friendly interface with a clear, collapsible sidebar for navigation. It's built on a client-server architecture, where a JavaScript-based API client handles all communication with a back-end REST API.

**Projects Content Viewer**: This section allows you to view and manage all your code projects. You can see project contents, add or remove classes, and even initiate a full project export.

**Export Project Task**: Here, you can create, monitor, and run tasks to export specific projects. This is useful for automating the packaging and distribution of your code.

**Exported Release**: This section provides a list of all your previously exported packages. You can easily browse and download these releases.

**Install Package Manager**: This utility section allows you to check the status of the application's API and perform installation-related tasks.

## Accessing the Application (aggiungere metodo da chiamare qui)

The Package Manager is a web application accessible via your browser. The default URL for the application is http://`<your-host>`:9092/csp/user/rest/packagemanager/. The port may vary depending on your setup.

## Containerized Deployment (Recommended)

The application is designed for containerized environments using Docker and Docker Compose. This ensures a consistent and isolated deployment experience. The following files are essential for this setup:

**Dockerfile**: This file defines the build process for the Docker image. It's based on the official intersystems/iris-community:latest-cd image. During the build, it copies your application's source code, an installer, and startup scripts into the image.

**docker-compose.yml**: This file orchestrates the Docker container. It maps the container's internal ports (1972, 52773) to your host machine's ports (9091, 9092), making the application accessible. It also creates a persistent volume for storing all your data and exported releases, ensuring they are not lost when the container is stopped or removed.

**Persistent Storage**: The docker-compose.yml file uses volumes to ensure data persistence. The ./storage directory on your host machine is mapped to the container's /durable directory for database persistence, while the ./exports directory on your host is mapped to /opt/irisapp/export to save your exported packages. This is crucial as any data not in a persistent volume is lost upon container shutdown.

**entrypoint.sh and iris.script**: These scripts work together to start the IRIS instance and import your application's classes into the active, durable database at every container start. This approach ensures your code is always loaded and ready to use, even after the container has been restarted.

### File Paths

To support the containerized environment, the application is configured to use the following file paths for temporary files and export tasks:

**Temporary files**: /opt/irisapp/export/packagemanager/tmp/

**Export tasks**: /opt/irisapp/export/packagemanager/task/

These paths are defined in the PackageManager.PackageManager include file, which acts as a central configuration.

### Manual Deployment (Alternative)

For non-containerized environments, the application can be installed directly into your InterSystems IRIS instance. You'll need to adjust the file paths in the configuration include file to point to a suitable directory in your host's file system, such as $system.Util.InstallDirectory()_"tmp/packagemanager/".

# How to Use

Launch the Application: The application is served from an InterSystems web server. Access the UI by navigating to the main page's URL in your web browser. The URL is automatically determined by the application at runtime.

Navigate: Use the sidebar on the left to switch between different sections

Perform Actions: Within each section, the UI will present options based on its functionality. All interactions are handled by the pmAPI client, which communicates with the back-end.

# Technical Details

The application is built using a combination of the InterSystems framework and web technologies:

**Front-end**: The UI is rendered using standard HTML, CSS, and JavaScript. All dynamic content loading and client-side logic are handled by the SectionsJS and WindowOnLoad methods.

**Back-end**: The core logic is implemented as a REST API in the PackageManager.API.REST class. It uses a URL map to route requests to specific methods (e.g., a POST request to /project/create is handled by the CreateProject method).

**Caching**: The API client uses different caching strategies (noCache, shortCache, longCache) to manage network requests and optimize performance. For dynamic data like task statuses, noCache is used to ensure you always see the latest information.
