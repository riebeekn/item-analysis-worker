#
# USAGE: 
# => ruby app/worker/worker.rb
#

require 'aws/s3'
require './app/models/job_facade'
require './app/services/database'
require './app/services/settings'
require './app/services/s3'

def run!
  # set-up
  Settings.load_env
  S3.load_config
  Database.load_config

  # loop infinite
  stop = false
  Signal.trap('INT') { stop = true }
  until stop
    job_found = JobFacade.process_next

    # keep looking for more jobs if a job was just processed
    # otherwise sleep for a bit
    pause_loop unless job_found
  end
end

def pause_loop
  print "."
  if ENV['WORKER_SLEEP_SECONDS']
    sleep(ENV['WORKER_SLEEP_SECONDS'].to_i)
  else
    sleep(10)
  end
end

run! if __FILE__==$0
