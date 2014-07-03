require 'logger'

# class that provides logging, usage:
# => either use the short-cut methods, i.e. Logging.info('some message')
# => or interact directly with the log via Logging.logger.info('some message')
class Logging

  def self.unknown(message)
    Logging.logger.unknown message
  end

  def self.fatal(message)
    Logging.logger.fatal message
  end

  def self.error(message)
    Logging.logger.error message
  end

  def self.warn(message)
    Logging.logger.warn message
  end

  def self.info(message)
    Logging.logger.info message
  end

  def self.debug(message)
    Logging.logger.debug message
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @logger ||= create
  end

  private
    def self.create
      @logger = Logger.new(STDOUT)
      @logger.formatter = proc do | severity, datetime, progname, msg |
        "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
      end
      @logger
    end
end