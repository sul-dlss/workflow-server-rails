# frozen_string_literal: true

# Returns the workflow template (currently from dor-services-app)
# NOTE: this isn't the raw template, it's the simplified version
# from WorkflowDefinitionDs#initial_workflow
class WorkflowTemplateService
  def self.template_for(workflow_name)
    new.template_for(workflow_name)
  end

  def template_for(workflow_name)
    client.workflows.initial(name: workflow_name)
  end

  private

  def client
    @client ||= Dor::Services::Client.configure(url: Settings.dor_services.url,
                                                username: Settings.dor_services.username,
                                                password: Settings.dor_services.password)
  end
end
