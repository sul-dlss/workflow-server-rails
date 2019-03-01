# Workflow service

[![](https://images.microbadger.com/badges/image/suldlss/workflow-server.svg)](https://microbadger.com/images/suldlss/workflow-server "Get your own image badge on microbadger.com") [![GitHub version](https://badge.fury.io/gh/sul-dlss%2Fworkflow-server-rails.svg)](https://badge.fury.io/gh/sul-dlss%2Fworkflow-server-rails)

This is a Rails-based workflow service that was originally created for testing but will ultimately replace SDR's Java-based workflow service.

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
GET    /:repo/objects/:druid/lifecycle
POST   /:repo/objects/:druid/versionClose
PUT    /:repo/objects/:druid/workflows/:workflow
PUT    /:repo/objects/:druid/workflows/:workflow/:process
GET    /:repo/objects/:druid/workflows
GET    /:repo/objects/:druid/workflows/:workflow
DELETE /:repo/objects/:druid/workflows/:workflow
GET    /workflow_archive
GET    /workflow_queue/lane_ids
GET    /workflow_queue/all_queued
GET    /workflow_queue
```
