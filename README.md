# Workflow service

## Build
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
