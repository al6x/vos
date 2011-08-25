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

        attrs = {}
        file_exists = file.exists?
        attrs[:file] = file_exists
        if file_exists
          attrs[:dir] = false
        else
          attrs[:dir] = dir_exists? path
        end

        if file_exists
          attrs[:size] = file.content_length
          attrs[:last_modified] = file.last_modified
        end

        attrs
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
        # TODO2 Performance lost, extra call to check file existence
        file = bucket.objects[path]
        file_exist = file.exists?
        raise "can't write, file #{original_path} already exist!" if !append and file_exist
        raise "can't write, dir #{original_path} already exist!" if dir_exists? path

        if append
          # there's no support for :append in Fog, so we just mimic it
          writer = Writer.new
          writer.write file.read if file_exist
          block.call writer
          file.write writer.data
        else
          writer = Writer.new
          block.call writer
          file.write writer.data
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
        raise Error, ":create_dir not supported!"
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
        tmp_dir = "/tmp/vfs_#{rand(10**6)}"
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