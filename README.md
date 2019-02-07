# Workflow service

This is the workflow service for the SDR.

## Build
Build the production image
```
docker build -t suldlss/workflow-server:latest .
```

## Run the development stack
```
$ docker-compose up -d
[FIRST RUN]
$ docker-compose run app rake db:setup
$ docker-compose stop
$ docker-compose up -d
[ -------- ]
```

If you want to connect to the container:
```
$ docker ps (to retrieve the container id)
$ docker exec -it (container id) /bin/sh
```

Testing:

```
docker-compose run -e "RAILS_ENV=test" app rake db:create db:migrate
docker-compose run -e "RAILS_ENV=test" app rake spec
```

## Routes:
```
GET http://localhost:3000/dor/objects/:druid/lifecycle
GET http://localhost:3000/dor/objects/:druid/workflows
GET http://localhost:3000/dor/objects/:druid/workflows/:workflows
PUT http://localhost:3000/dor/objects/:druid/workflows/:workflows
GET http://localhost:3000/workflow_archive
```
