require 'aws/s3'

class S3
  def self.load_config
    unless Settings.SKIP_S3_UPLOAD? && !Settings.PULL_INPUT_FILES_FROM_S3?
      AWS::S3::Base.establish_connection!(
        :access_key_id     => Settings.AWS_ACCESS_KEY_ID,
        :secret_access_key => Settings.AWS_SECRET_ACCESS_KEY
      )
    end
  end

  def self.upload(file, job_id, tmp = true)
    unless Settings.SKIP_S3_UPLOAD?
      if tmp
        aws_file = "#{job_id}/tmp/#{aws_filename_from(file)}"
      else
        aws_file = "#{job_id}/output/#{aws_filename_from(file)}"
      end
      AWS::S3::S3Object.store(
        aws_file, 
        open(file), 
        Settings.AWS_BUCKET, access: :public_read
      )

      puts "Uploaded \"#{aws_file}\" to S3"
    end
  end

  def self.get(file, job_id, tmp = true)
    if Settings.SKIP_S3_UPLOAD?
      File.read(file)
    else
      if tmp
        aws_file = "#{job_id}/tmp/#{aws_filename_from(file)}"
      else
        aws_file = "#{job_id}/inputs/#{aws_filename_from(file)}"
      end
      AWS::S3::S3Object.value aws_file, Settings.AWS_BUCKET
    end
  end

  def self.download_file(file, job_id)
    filename = aws_filename_from(file)
    local_filename = "#{Settings.TMP_DIR}#{job_id}/#{filename}"
    aws_file = AWS::S3::S3Object.find "#{job_id}/inputs/#{filename}", Settings.AWS_BUCKET
    File.open(local_filename, 'w') { |file| file.write aws_file.value }
    local_filename
  end

  def self.delete(file, job_id)
    unless Settings.SKIP_S3_UPLOAD?
      aws_file = "#{job_id}/tmp/#{aws_filename_from(file)}"
      AWS::S3::S3Object.delete(aws_file, "nico44-ian")
    end
  end

  private
    def self.aws_filename_from(file)
      File.basename(file)
    end
end