require 'digest/md5'
require 'fileutils'
require 'pathname'

module Sprockets
  module Cache
    # A simple file system cache store.
    #
    #     environment.cache = Sprockets::Cache::FileStore.new("/tmp")
    #
    class FileStore
      def self.default_logger
        logger = Logger.new($stderr)
        logger.level = Logger::FATAL
        logger
      end

      def initialize(root)
        @root = Pathname.new(root)
        @logger = self.class.default_logger
      end

      # Lookup value in cache
      def [](key)
        pathname = @root.join(key)
        if pathname.exist?
          pathname.open('rb') do |f|
            begin
              Marshal.load(f)
            rescue Exception => e
              @logger.error do
                "#{self.class}[#{path}] could not be unmarshaled: " +
                  "#{e.class}: #{e.message}"
              end
              nil
            end
          end
        else
          nil
        end
      end

      # Save value to cache
      def []=(key, value)
        # Ensure directory exists
        FileUtils.mkdir_p @root.join(key).dirname

        @root.join(key).open('w') { |f| Marshal.dump(value, f)}
        value
      end
    end
  end
end
