# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

require_relative 'environment'

# Learn more: http://github.com/javan/whenever
job_type :no_warnings_runner,
         "cd :path && RUBYOPT='-W0' bin/rails runner -e :environment ':task' :output && curl --silent https://api.honeybadger.io/v1/check_in/:check_in"

# NOTE: this job uses HB checkins.
# If you change the schedule, edit the HB checkin at https://app.honeybadger.io/projects/58890/check_ins
every 60.minutes do
  # Currently running Monitor (notification only for stuck workflow steps) instead of Sweeper (notification and requeueing).
  # If monitoring alone isn't adequate (e.g., due to large numbers of Redis timeouts), we may want to re-enable the sweeper.
  # no_warnings_runner 'Sweeper.sweep'
  set :check_in, Settings.honeybadger_checkins.workflow_monitor
  no_warnings_runner 'WorkflowMonitor.monitor'
end
