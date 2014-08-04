#
# Provides a way of running a job manually from the console for manual 
# testing purposes.
# 
# Basically just creates a job based on the input file passed in (or
# defaults to 10q_30p.csv) and then calls JobFacade.process_next
#
# USAGE: 
# => ruby app/console/run_job.rb
# => ruby app/console/run_job.rb --filename "./sample_data_files/50q_30p.csv"
#
require 'trollop'
require 'active_record'
require './app/models/job_facade'
require './app/services/database'
require './app/services/settings'
require './app/services/s3'

def run!
  # require './app/pdfs/toc_test'
  # TocTest.create
  # exit
  # set-up
  Settings.load_env
  S3.load_config
  Database.load_config
  parse_command_line

  # create a job to test
  create_job

  # process it
  JobFacade.process_next
end

def parse_command_line
  @opts = Trollop::options do
    opt :datafile, "Data file to process", type: String, default: "./sample_data_files/ctt_data.csv"
    opt :keyfile, "Key file to use", type: String, default: "./sample_data_files/ctt_data.key.csv"
  end
end

def create_job
  job = Job.new
  job.status = "Pending"
  job.data_file = @opts[:datafile]
  job.key_file = @opts[:keyfile]
  job.save!
  if Settings.PULL_INPUT_FILES_FROM_S3?
    upload_input_files_to_s3(job.id, job.data_file, job.key_file)
  end
  job
end

def upload_input_files_to_s3(job_id, data_file, key_file)
  aws_data_file_name = "#{job_id}/inputs/#{File.basename(data_file)}"
  aws_key_file_name = "#{job_id}/inputs/#{File.basename(key_file)}"
  s3_upload(aws_data_file_name, data_file)
  s3_upload(aws_key_file_name, key_file)
end

def s3_upload(aws_file, local_file)
  AWS::S3::S3Object.store(
    aws_file, 
    open(local_file), 
    Settings.AWS_BUCKET, access: :public_read
  )
end

run! if __FILE__==$0