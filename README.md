# Workflow service

This is a workflow service that is set up just for testing. It's only using sqlite,
so it's not something to use in production.

## Build
First create the database (this gets bundled into the image)
```
RAILS_ENV=production rake db:migrate
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
GET http://localhost:3000/dor/objects/:druid/lifecycle
GET http://localhost:3000/dor/objects/:druid/workflows
GET http://localhost:3000/dor/objects/:druid/workflows/:workflows
PUT http://localhost:3000/dor/objects/:druid/workflows/:workflows
GET http://localhost:3000/workflow_archive
```


## TODO

### Remove the STOMP dependency
It would be great if we could remove the dependency on STOMP messaging.
One way we could do this is if we only allowing update messages to come from dor-services-app.
dor-services-app could send a message to STOMP.

Another possibility would be removing the workflow status from the Argo SOLR index.
If something needs to know about statuses, it should ask the workflow service directly.

### Remove the dor-service-app dependency.
All calls should tell us what version of the object it is operating on.
