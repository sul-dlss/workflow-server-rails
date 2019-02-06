# Workflow service

[![](https://images.microbadger.com/badges/image/suldlss/workflow-server.svg)](https://microbadger.com/images/suldlss/workflow-server "Get your own image badge on microbadger.com")

This is a Rails-based workflow service that was originally created for testing but will ultimately replaced our current Java-based worfklow service.

## Build
First create the database (this gets bundled into the image)
```
RAILS_ENV=production rails db:migrate
```
Build the image
```
docker build -t suldlss/workflow-server:latest .
```

## Run
```
docker run -p 3000:3000 suldlss/workflow-server:latest
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
