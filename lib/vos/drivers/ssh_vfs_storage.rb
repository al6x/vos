module Vos
  module Drivers
    module SshVfsStorage
      class Writer
        def initialize out
          @out = out
        end

        def write data
          data = data.force_encoding(Encoding::ASCII_8BIT)
          @out.write data
        end
      end

      #
      # Attributes
      #
      def attributes path
        path = with_root path
        path = fix_path path

        stat = sftp.stat! path
        attrs = {}
        attrs[:file] = stat.file?
        attrs[:dir] = stat.directory?
        # stat.symlink?

        # attributes special for file system
        time = stat.mtime
        attrs[:updated_at] = time && Time.at(time)
        attrs[:size]       = stat.size if attrs[:file]

        attrs
      rescue Net::SFTP::StatusException
        nil
      end

      def set_attributes path, attrs
        path = with_root path
        path = fix_path path

        raise 'not supported'
      end

      #
      # File
      #
      def read_file path, &block
        path = with_root path
        path = fix_path path

        sftp.file.open path, 'r' do |is|
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
          path = with_root path
          path = fix_path path
          sftp.file.open path, 'w' do |out|
            block.call Writer.new(out)
          end
        end
      end

      def delete_file path
        path = with_root path
        path = fix_path path
        sftp.remove! path
      end

      # def move_file path
      #   raise 'not supported'
      # end


      #
      # Dir
      #
      def create_dir path
        path = with_root path
        path = fix_path path
        sftp.mkdir! path
      end

      def delete_dir path
        path = with_root path
        path = fix_path path
        exec "rm -r #{path}"
      end

      def each_entry path, query, &block
        path = with_root path
        path = fix_path path

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
        tmp_dir = "/tmp_#{rand(10**6)}"
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

      def _delete_root_dir
        raise 'refuse to delete / directory!' if root == '/'
        exec "rm -r #{@root}" unless root.empty?
      end

      def _create_root_dir
        raise 'refuse to create / directory!' if root == '/'
        sftp.mkdir! root unless root.empty?
      end

      protected
        def root
          @root || raise('root not defined!')
        end

        def with_root path
          path == '/' ? root : root + path
        end
    end
  end
end
