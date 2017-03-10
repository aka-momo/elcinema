module Elcinema
  class Logger < ::Logger
    def self.default
      @logger ||= begin
        new(STDOUT).tap do |logger|
          logger.progname = "Elcinema/#{VERSION}"
          logger.level    = Logger::WARN
        end
      end
    end
  end
end
