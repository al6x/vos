module Vos
  module Drivers
    module S3VfsStorage
      class Error < StandardError
      end

      class Writer
        attr_reader :data
        def initialize
          @data = ""
        end

        def write data
          @data << data
        end
      end

      #
      # Attributes
      #
      def attributes path
        path = normalize_path(path)
        return {dir: true, file: false} if path.empty?

        file = bucket.objects[path]
        if file.exists?
          attrs = {}
          attrs[:file] = true
          attrs[:dir] = false
          attrs[:size] = file.content_length
          attrs[:updated_at] = file.last_modified
          attrs
        else
          # There's no dirs in S3, so we always return nil
          nil
        end
      end

      def set_attributes path, attrs
        raise 'not supported'
      end

      #
      # File
      #
      def read_file path, &block
        path = normalize_path path
        file = bucket.objects[path]
        block.call file.read
      end

      def write_file original_path, append, &block
        path = normalize_path original_path

        file = bucket.objects[path]
        if append
          # there's no support for :append in Fog, so we just mimic it
          writer = Writer.new
          writer.write file.read if file.exists?
          block.call writer
          file.write writer.data, acl: acl
        else
          writer = Writer.new
          block.call writer
          file.write writer.data, acl: acl
        end
      end

      def delete_file path
        path = normalize_path path
        file = bucket.objects[path]
        file.delete
      end


      #
      # Dir
      #
      def create_dir path
        # there's no concept of dir in s
        # raise Error, ":create_dir not supported!"
      end

      def delete_dir path
        path = normalize_path path

        bucket.as_tree(prefix: path).children.each do |obj|
          if obj.branch?
            delete_dir "/#{obj.prefix}"
          elsif obj.leaf?
            bucket.objects[obj.key].delete
          else
            raise "unknow node type!"
          end
        end
      end

      def each_entry path, query, &block
        path = normalize_path path
        raise "S3 not support :each_entry with query!" if query

        bucket.as_tree(prefix: path).children.each do |obj|
          if obj.branch?
            block.call obj.prefix.sub("#{path}/", '').sub(/\/$/, ''), :dir
          elsif obj.leaf?
            block.call obj.key.sub("#{path}/", ''), :file
          else
            raise "unknow node type!"
          end
        end
      end

      #
      # Special
      #
      def tmp &block
        tmp_dir = "/tmp/#{rand(10**6)}"
        if block
          begin
            block.call tmp_dir
          ensure
            delete_dir tmp_dir
          end
        else
          tmp_dir
        end
      end

      def local?; false end

      protected
        def dir_exists? path
          path = normalize_path path
          catch :break do
            bucket.as_tree(prefix: path).children.each do
              throw :break, true
            end
            false
          end
        end

        def normalize_path path
          path.sub(/^\//, '')
        end
    end
  end
end