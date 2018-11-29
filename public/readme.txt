To build image and host the server perform the following steps:

1) Place Dockerfile and docker-compose.yml in your project's root directory.

2) Open terminal in the project's root directory.

3) Run: docker-compose up --build

4) Goto localhost:3000 to view your project.

PS- If you're using any database adapter i.e Mysql or Postgres, go to database.yml and configure host as 'db'.
