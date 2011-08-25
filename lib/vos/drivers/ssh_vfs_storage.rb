module Vos
  module Drivers
    module SshVfsStorage
      class Writer
        def initialize out
          @out = out
        end

        def write data
          @out.write data
        end
      end

      #
      # Attributes
      #
      def attributes path

        stat = sftp.stat! fix_path(path)
        attrs = {}
        attrs[:file] = stat.file?
        attrs[:dir] = stat.directory?
        # stat.symlink?

        # attributes special for file system
        attrs[:updated_at] = stat.mtime

        attrs
      rescue Net::SFTP::StatusException
        {file: false, dir: false}
      end

      def set_attributes path, attrs
        raise 'not supported'
      end

      #
      # File
      #
      def read_file path, &block
        sftp.file.open fix_path(path), 'r' do |is|
          while buff = is.gets
            block.call buff
          end
        end
      end

      def write_file path, append, &block
        # there's no support for :append in Net::SFTP, so we just mimic it
        if append
          attrs = attributes(path)
          data = if attrs[:file]
              os = ""
              read_file(path){|buff| os << buff}
              delete_file path
              os
          elsif attrs[:dir]
            raise "can't append to dir!"
          else
            ''
          end
          write_file path, false do |writer|
            writer.write data
            block.call writer
          end
        else
          sftp.file.open fix_path(path), 'w' do |out|
            block.call Writer.new(out)
          end
        end
      end

      def delete_file remote_file_path
        sftp.remove! fix_path(remote_file_path)
      end

      # def move_file path
      #   raise 'not supported'
      # end


      #
      # Dir
      #
      def create_dir path
        sftp.mkdir! path
      end

      def delete_dir path
        exec "rm -r #{path}"
      end

      def each_entry path, query, &block
        raise "SshVfsStorage not support :each_entry with query!" if query

        sftp.dir.foreach path do |stat|
          next if stat.name == '.' or stat.name == '..'
          if stat.directory?
            block.call stat.name, :dir
          else
            block.call stat.name, :file
          end
        end
      end

      # def efficient_dir_copy from, to, override
      #   return false if override # sftp doesn't support this behaviour
      #
      #   from.storage.open_fs do |from_fs|
      #     to.storage.open_fs do |to_fs|
      #       if from_fs.local?
      #         sftp.upload! from.path, fix_path(to.path)
      #         true
      #       elsif to_fs.local?
      #         sftp.download! fix_path(from.path), to.path, recursive: true
      #         true
      #       else
      #         false
      #       end
      #     end
      #   end
      # end

      #
      # Special
      #
      def tmp &block
        tmp_dir = "/tmp/vfs_#{rand(10**6)}"
        if block
          begin
            create_dir tmp_dir
            block.call tmp_dir
          ensure
            delete_dir tmp_dir
          end
        else
          create_dir tmp_dir
          tmp_dir
        end
      end

      def local?; false end
    end
  end
end