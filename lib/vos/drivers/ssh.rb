require 'net/ssh'
require 'net/sftp'

module Vos
  module Drivers
    class Ssh < Abstract      
      module VfsStorage
        # 
        # Attributes
        # 
        def attributes path

          stat = sftp.stat! fix_path(path)
          attrs = {}
          attrs[:file] = stat.file?
          attrs[:dir] = stat.directory?
          # stat.symlink?
          attrs                  
        rescue Net::SFTP::StatusException
          {}
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
            data = if attrs
              if attrs[:file]
                os = ""
                read_file(path){|buff| os << buff}
                delete_file path                
                os
              else
                raise "can't append to dir!"
              end
            else
              ''
            end
            write_file path, false do |writer|
              writer.call data
              block.call writer
            end
          else
            sftp.file.open fix_path(path), 'w' do |os|
              writer = -> buff {os.write buff}
              block.call writer
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

        def each path, &block
          sftp.dir.foreach path do |stat|
            next if stat.name == '.' or stat.name == '..'
            if stat.directory?
              block.call stat.name, :dir
            else
              block.call stat.name, :file
            end
          end
        end

        # def move_dir path
        #   raise 'not supported'
        # end


        # 
        # Special
        # 
        # def upload_directory from_local_path, to_remote_path
        #   sftp.upload! from_local_path, fix_path(to_remote_path)
        # end
        # 
        # def download_directory from_remote_path, to_local_path
        #   sftp.download! fix_path(from_remote_path), to_local_path, :recursive => true
        # end

        def tmp &block
          tmp_dir = "/tmp/vfs_#{rand(10**3)}"        
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
      end
      
      def initialize options = {}
        super
        raise "ssh options not provided!" unless options[:ssh]
        raise "invalid ssh options!" unless options[:ssh].is_a?(Hash)
      end
      
      
      # 
      # Establishing SSH channel
      # 
      def open &block
        if block
          if @ssh
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
          unless @ssh
            ssh_options = self.options[:ssh].clone
            host = options[:host] || raise('host not provided!')
            user = ssh_options.delete(:user) || raise('user not provied!')
            @ssh = Net::SSH.start(host, user, ssh_options)
            @sftp = @ssh.sftp.connect
          end
        end
      end            
    
      def close                        
        if @ssh
          @ssh.close
          # @sftp.close not needed
          @ssh, @sftp = nil
        end
      end

      def to_s; options[:host] end
      
      
      # 
      # Vfs
      # 
      include VfsStorage
      alias_method :open_fs, :open
      
      
      # 
      # Shell
      # 
      def exec command
        # somehow net-ssh doesn't executes ~/.profile, so we need to execute it manually
        # command = ". ~/.profile && #{command}"

        stdout, stderr, code, signal = hacked_exec! ssh, command

        return code, stdout, stderr
      end                              
      
      def bash command
        # somehow net-ssh doesn't executes ~/.profile, so we need to execute it manually
        # command = ". ~/.profile && #{command}"

        stdout_and_stderr, stderr, code, signal = hacked_exec! ssh, command, true

        return code, stdout_and_stderr
      end
      
      
      protected
        attr_accessor :ssh, :sftp
      
        def fix_path path
          path.sub(/^\~/, home)
        end
        
        def home
          unless @home
            command = 'cd ~; pwd'
            code, stdout, stderr = exec command
            raise "can't execute '#{command}'!" unless code == 0
            @home = stdout.gsub("\n", '')    
          end
          @home
        end
      
        # taken from here http://stackoverflow.com/questions/3386233/how-to-get-exit-status-with-rubys-netssh-library/3386375#3386375
        def hacked_exec!(ssh, command, merge_stdout_and_stderr = false, &block)
          stdout_data = ""
          stderr_data = ""
          exit_code = nil
          exit_signal = nil
        
          channel = ssh.open_channel do |channel|
            channel.exec(command) do |ch, success|
              raise "could not execute command: #{command.inspect}" unless success

              channel.on_data{|ch2, data| stdout_data << data}
              channel.on_extended_data do |ch2, type, data| 
                stdout_data << data if merge_stdout_and_stderr
                stderr_data << data
              end
              channel.on_request("exit-status"){|ch,data| exit_code = data.read_long}
              channel.on_request("exit-signal"){|ch, data| exit_signal = data.read_long}
            end          
          end  
        
          channel.wait      
        
          [stdout_data, stderr_data, exit_code, exit_signal]
        end    
    end
  end
end