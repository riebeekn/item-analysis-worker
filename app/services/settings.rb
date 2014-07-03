class Settings
  def self.load_env
    heroku_env = "./config/heroku_env.rb"
    load(heroku_env) if File.exists?(heroku_env)
  end

  def self.AWS_BUCKET
    ENV['AWS_BUCKET']
  end

  # def self.AWS_UPLOAD_BUCKET
  #   ENV['AWS_UPLOAD_BUCKET']
  # end

  def self.AWS_ACCESS_KEY_ID
    ENV['AWS_ACCESS_KEY_ID']
  end

  def self.AWS_SECRET_ACCESS_KEY
    ENV['AWS_SECRET_ACCESS_KEY']
  end

  def self.TMP_DIR
    ENV['TMP_DIR']
  end

  def self.SKIP_S3_UPLOAD?
    ENV['SKIP_S3_UPLOAD'] == "true"
  end

  def self.RUN_MIRT?
    ENV['RUN_MIRT'] == "true"
  end

  def self.CLEAN_LOCAL_TEMP?
    ENV['CLEAN_LOCAL_TEMP'] == "true"
  end

  def self.CLEAN_S3_TEMP?
    ENV['CLEAN_S3_TEMP'] == "true"
  end

  def self.PULL_INPUT_FILES_FROM_S3?
    ENV['PULL_INPUT_FILES_FROM_S3'] == "true"
  end
end