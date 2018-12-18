# Change the name from the default 'wfs_rails_workflows' to what already
# exists in the legacy Oracle database
WfsRails::Workflow.table_name = 'workflow'
