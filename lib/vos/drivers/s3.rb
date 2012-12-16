require 'aws'
require 'vos/drivers/s3_vfs_storage'

module Vos
  module Drivers
    class S3
      attr_accessor :box
      attr_reader :connection, :bucket

      def initialize options = {}
        options = options.clone
        @bucket_name = options.delete(:bucket) || raise("S3 bucket not provided!")
        @write_options = {:acl => :public_read}.options.delete(:write_options)
        @options = options
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
            @connection = ::AWS::S3.new self.options.clone
            @bucket = @connection.buckets[bucket_name]
          end
        end
      end

      def close; end

      #
      # Vfs
      #
      include S3VfsStorage


      #
      # Miscellaneous
      #
      def inspect; "https://#{bucket_name}.s3.amazonaws.com" end
      alias_method :to_s, :inspect

      def _clear
        bucket.objects.each{|o| o.delete}
      end

      protected
        attr_reader :options, :bucket_name, :write_options
    end
  end
end
