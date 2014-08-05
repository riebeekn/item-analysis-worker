class Database
  def self.load_config
    env = ENV['RACK_ENV'] || 'development'
    Mongoid.load!('./././config/mongoid.yml', env)
    # Mongoid.logger.level = Logger::DEBUG
    # Moped.logger.level = Logger::DEBUG
  end
end