# Package Manager REST API Reference

This document provides a comprehensive reference for the Package Manager REST API, accessible via the `PackageManager.API.REST` class.

The API class `PackageManager.API.REST` provides a complete REST API to **manage projects, export files, and handle tasks** related to the Package Manager.REST Endpoints

This includes endpoints for:

* Creating, retrieving, updating, and deleting projects.
* Adding and removing classes from projects.
* Exporting specific projects or sets of classes.
* Retrieving content from the current namespace.
* Creating, running, updating, and deleting export tasks.
* Checking the API status and retrieving the OpenAPI specification.

### Project-Related Calls

| **Endpoint**              | **Method** | **Description**                                               |
| ------------------------------- | ---------------- | ------------------------------------------------------------------- |
| `/project/create`             | `POST`         | Creates a new project.                                              |
| `/projects`                   | `GET`          | Retrieves a list of all existing projects.                          |
| `/project/export/:projectId`  | `GET`          | Exports a specific project by its ID.                               |
| `/project/content/:projectId` | `GET`          | Retrieves the content (classes and routines) of a specific project. |
| `/project/content`            | `GET`          | Retrieves the content of all projects.                              |
| `/project/update/:projectId`  | `POST`         | Updates the description of a specific project.                      |
| `/project/delete/:projectId`  | `DELETE`       | Deletes a project by its ID.                                        |
| `/project/add/:projectId`     | `POST`         | Adds classes to a project.                                          |
| `/project/remove/:projectId`  | `PUT`          | Removes classes from a project.                                     |

### Export Classes Calls

| **Endpoint**  | **Method** | **Description**               |
| ------------------- | ---------------- | ----------------------------------- |
| `/classes/export` | `POST`         | Exports a specified set of classes. |

### Namespace Content Calls

| **Endpoint**           | **Method** | **Description**                                                |
| ---------------------------- | ---------------- | -------------------------------------------------------------------- |
| `/namespace/content/:type` | `GET`          | Retrieves all files of a specific type within the current namespace. |
| `/namespace/content`       | `GET`          | Retrieves all files within the current namespace.                    |

### Task-Related Calls

| **Endpoint**              | **Method** | **Description**                        |
| ------------------------------- | ---------------- | -------------------------------------------- |
| `/task/create`                | `POST`         | Creates a new export task.                   |
| `/task/existing`              | `GET`          | Checks for existing tasks.                   |
| `/task/delete/:taskId`        | `DELETE`       | Deletes a task by its ID.                    |
| `/task/run/:taskId`           | `GET`          | Runs a specific task.                        |
| `/task/:taskId`               | `GET`          | Retrieves information about a specific task. |
| `/task/update/:taskId`        | `POST`         | Updates a specific task.                     |
| `/task/updateclasses/:taskId` | `POST`         | Updates the classes associated with a task.  |
| `/task/releases/`             | `GET`          | Retrieves a list of available releases.      |
| `/task/release/download`      | `POST`         | Downloads a specific release.                |

### Utility Calls

| **Endpoint** | **Method** | **Description**                                                                 |
| ------------------ | ---------------- | ------------------------------------------------------------------------------------- |
| `/api/ping`      | `GET`          | Checks if the API is reachable and working. Returns a timestamp and a status message. |
| `/_spec`         | `GET`          | Returns the OpenAPI (Swagger) specification for this API.                             |
| `/`              | `GET`          | Returns basic server information, including the version.                              |

---

# Package Manager UI API Client

The `PackageManager.UI.APIClient` class provides a client-side JavaScript interface for the REST API. This script, included in the UI, makes the `PackageManagerAPI` (and its alias `pmAPI`) object globally available in the browser.

The client is built using modern JavaScript (`async`/`await` and `fetch`) and handles requests with different caching strategies (`noCache`, `shortCache`, `longCache`). All methods return a JavaScript `Promise`, allowing for easy chaining with `.then()` and `.catch()` blocks for handling success and error cases.

### Core Functions

The `PackageManagerAPI` object exposes a set of functions that correspond to the REST endpoints. Here are a few examples:

* **`PackageManagerAPI.ping()`** : Checks the API status.

```
  PackageManagerAPI.ping()
      .then(response => {
          console.log(response.message);
      })
      .catch(error => {
          console.error("Ping failed:", error);
      });

```

* **`PackageManagerAPI.getProjects(cacheStrategy)`** : Fetches the list of projects. The `cacheStrategy` parameter can be one of `'noCache'`, `'shortCache'`, or `'longCache'`.

```
  const cacheStrategy = 'noCache';
  PackageManagerAPI.getProjects(cacheStrategy)
      .then(projects => {
          console.log("Projects loaded successfully:", projects);
          // Render the project list in the UI
      })
      .catch(error => {
          console.error("Failed to load projects:", error);
          // Display an error message to the user
      });

```

* **`PackageManagerAPI.createProject(projectData)`** : Creates a new project by sending a JSON payload.

```
  const newProject = { name: "My New Project", description: "A project for my work." };
  PackageManagerAPI.createProject(newProject)
      .then(response => {
          console.log("Project created:", response);
      })
      .catch(error => {
          console.error("Creation failed:", error);
      });

```
