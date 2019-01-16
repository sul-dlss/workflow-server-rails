# frozen_string_literal: true

##
# API for handling workflow queue requests.
class WorkflowQueuesController < ApplicationController
  def lane_ids
    repository, datastream, process = params[:step].split(':')
    @lanes = WorkflowStep.where(repository: repository,
                                datastream: datastream,
                                process: process,
                                status: 'waiting').distinct.pluck('lane_id')
  end
end
