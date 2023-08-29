# Workflow service

[![CircleCI](https://circleci.com/gh/sul-dlss/workflow-server-rails.svg?style=svg)](https://circleci.com/gh/sul-dlss/workflow-server-rails)
[![Test Coverage](https://api.codeclimate.com/v1/badges/cc78d20264a4eaf8a782/test_coverage)](https://codeclimate.com/github/sul-dlss/workflow-server-rails/test_coverage)
[![Maintainability](https://api.codeclimate.com/v1/badges/cc78d20264a4eaf8a782/maintainability)](https://codeclimate.com/github/sul-dlss/workflow-server-rails/maintainability)
[![](https://images.microbadger.com/badges/image/suldlss/workflow-server.svg)](https://microbadger.com/images/suldlss/workflow-server "Get your own image badge on microbadger.com")

This is a Rails-based workflow service that replaced SDR's Java-based workflow service.  It is consumed by the users of dor-workflow-client (argo, hydra_etd, pre-assembly, dor-indexing-app, dor-services-app, robots, technical-metadata-service, sdr-api, was-registar-app, preservation-catalog) and *soon* the goobi application (currently proxying through dor-services-app).

The workflows are defined by xml templates which are stored in [config/workflows](https://github.com/sul-dlss/workflow-server-rails/tree/main/config/workflows).  The templates define a dependency graph. When all prerequisites for a step are complete, the step is marked as "queued" and a corresponding job is pushed into Sidekiq.  Some steps are are marked `skip-queue="true"` which means they are merely logged events and do not kick off a Sidekiq process.


## Sidekiq Jobs

When a workflow step is set to done, the service calculates which workflow steps
are ready to be worked on and enqueues Sidekiq jobs for them.  The queues are named
for the workflow and priority.  For example:

```
accessionWF_high
accessionWF_default
accessionWF_low
assemblyWF_high
assemblyWF_default
assemblyWF_low
disseminationWF_high
disseminationWF_default
disseminationWF_low
...
```

## Developers

### Configuration
The credentials for SideKiq Pro must be provided (e.g., in `.bash_profile`): `export BUNDLE_GEMS__CONTRIBSYS__COM=xxxx:xxxx` (available from shared_configs).

### Build
Build the production image:
```
docker build -t suldlss/workflow-server:latest .
```

### Run the development stack
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

## Testing:

You need to be running the postgres database.  One of the easiest ways is to use the docker-compose db via separate terminal window:

```
docker-compose up db
```

The first time you run tests, you may need to run this before the tests (from another terminal window):

`RAILS_ENV=test ./bin/rails db:create db:migrate`

To run tests:
```
bundle exec rspec
```

To shut down postgres afterwards,

- cntl-C in your existing docker-compose terminal window.
- ```docker-compose down``` afterwards

## Routes:
`GET    /objects/:druid/lifecycle` - Returns the milestones in the lifecycle that have been completed


`POST   /objects/:druid/versionClose` - Set all versioningWF steps to 'complete' and starts a new accessionWF unless `create-accession=false` is passed as a parameter.


These methods deal with the workflow for a single object
```
POST   /objects/:druid/workflows/:workflow
GET    /objects/:druid/workflows
GET    /objects/:druid/workflows/:workflow
DELETE /objects/:druid/workflows/:workflow
```

These methods deal with a single step for a single object
```
PUT    /objects/:druid/workflows/:workflow/:process
GET    /objects/:druid/workflows/:workflow/:process
```

Return the list of workflow templates
`GET   /workflow_templates`

Return the list of steps for the given workflow template
`GET   /workflow_templates/:workflow`

These processes are used by robot-master to discover which steps need to be performed.
```
GET    /workflow_queue/lane_ids
GET    /workflow_queue/all_queued
GET    /workflow_queue
```

## Deploy
### Logs
Logs are located in `/var/log/httpd`.

## Reset Process (for QA/Stage)
### Steps

1. Reset the database: `bin/rails -e p db:reset`
