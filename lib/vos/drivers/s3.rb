require 'aws'
require 'vos/drivers/s3_vfs_storage'

module Vos
  module Drivers
    class S3
      attr_reader :connection, :bucket

      DEFAULT_OPTIONS = {
        # public: true
      }

      def initialize initialization_options, options = {}
        @initialization_options, @options = initialization_options, DEFAULT_OPTIONS.merge(options)
      end


      #
      # Establishing SSH channel
      #
      def open &block
        if block
          if connection
            block.call self
          else
            begin
              open
              block.call self
            ensure
              close
            end
          end
        else
          unless connection
            @connection = ::AWS::S3.new self.initialization_options.clone
            unless bucket = options[:bucket]
              raise("S3 bucket not provided (use Vos::Drivers::S3.new({initialization options ...}, {bucket: '<bucket_name>'}))!")
            end
            @bucket = @connection.buckets[bucket]
          end
        end
      end

      def close; end

      #
      # Vfs
      #
      include S3VfsStorage
      alias_method :open_fs, :open


      #
      # Miscellaneous
      #
      def inspect; "<#{self.class.name} #{initialization_options.inspect}, #{options.inspect}>" end
      alias_method :to_s, :inspect

      protected
        attr_reader :initialization_options, :options
    end
  end
end