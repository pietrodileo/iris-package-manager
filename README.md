* ```bash
  docker-compose up -d
  ```

http://localhost:9092/csp/sys/UtilHome.csp

Password1234

docker compose down -v
docker compose up --build


After this, when container is running, you should activate client side mode from vscode. 

To do that:

- Create a namespace connection to the IRIS container through settings.json
- Click on: View -> Command Palette -> ObjectScript: Connect Folder to Server Namespace... -> Select the container namespace
- Start working on files into the local src/ folder. Any change will be reflected to the container as well since now the folder base are synchronised and the local src folder has become the source of truth.
- This can be used with git source control as well. Just create a repository and do git init into the main project local folder, then connect it to the repo. Any local change will be synch both with git and iris container.
