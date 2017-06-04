begin
  require 'byebug'
rescue LoadError
  nil
end

require 'logger'

require 'elcinema/version'
require 'elcinema/logger'

require 'elcinema/lib/cached_attr'

require 'elcinema/scrapper'
require 'elcinema/model'
require 'elcinema/movie'
require 'elcinema/theater'

module Elcinema
  def self.logger
    @logger ||= Logger.default
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.debug
    @debug ||= false
  end

  def self.debug=(enabled)
    @debug = if enabled
               logger.level = Logger::DEBUG
               true
             else
               logger.level = Logger::WARN
               false
             end
  end
end
