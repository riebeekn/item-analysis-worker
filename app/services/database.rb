class Database
  def self.load_config
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/item_analysis_development') # change this to read in from config?
    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :port     => db.port,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end
end