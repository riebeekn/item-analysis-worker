#
# Not truly a request spec but acts somewhat like one, tests the higher
# level functionality and work flow of the over-all job process
#
require 'spec_helper'
require './app/models/job_facade'
require './app/services/settings'
require './app/services/s3'

describe "JobFacade" do
  describe ".process_next" do
    after { Job.destroy_all }
    
    context "when no jobs need processing" do
      before do
        @processing_job = FactoryGirl.create(:job, status: Job::PROCESSING)
        @done_job = FactoryGirl.create(:job, status: Job::DONE)
      end

      it "should return false" do
        JobFacade.process_next.should eq false
      end
    end

    context "when a job is found to process" do
      before { @job_to_process = FactoryGirl.create(:job, status: Job::PENDING) }
      after do 
        dir = "./tmp/#{@job_to_process.id}"
        FileUtils.rm_rf dir 
      end

      it "should return true" do
        JobFacade.process_next.should eq true
      end

      it "should stop with error and message if scoring fails" do
        # no input file is set which is what causes the scoring failure
        JobFacade.process_next 
        @job_to_process.reload.status.should eq Job::ERROR
        @job_to_process.message.should eq "Scoring failed"
      end
    end
  end
end