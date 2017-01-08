class Log
  def self.debug(msg, &block)
    Rails.logger.debug(msg, &block)
  end

  def self.info(msg, &block)
    Rails.logger.info(msg, &block)
  end

  def self.warn(msg, &block)
    Rails.logger.warn(msg, &block)
  end

  def self.error(msg, &block)
    Rails.logger.error(msg, &block)
  end

  def self.fatal(msg, &block)
    Rails.logger.fatal(msg, &block)
  end

  def self.unknown(msg, &block)
    Rails.logger.unknown(msg, &block)
  end

  def self.exception(exception, params = {}, &block)
    # Log the error...
    msg = "#{exception.class} (#{exception.message})"
    msg += "\nParameters: #{params}" if params.present?
    msg += "\n#{exception.backtrace.join("\n")}"
    Rails.logger.error(msg, &block)
  end

end
