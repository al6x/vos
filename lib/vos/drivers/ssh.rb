module Vos
  module Drivers
    class Ssh < Abstract      
      def initialize options = {}
        super
        raise "ssh options not provided!" unless options[:ssh]
        raise "invalid ssh options!" unless options[:ssh].is_a?(Hash)
      end
      
      
      # 
      # Establishing SSH channel
      # 
      def open      
        ssh_options = self.options[:ssh].clone
        host = options[:host] || raise('host not provided!')
        user = ssh_options.delete(:user) || raise('user not provied!')
        @ssh = Net::SSH.start(host, user, ssh_options)
        @sftp = @ssh.sftp.connect
      end
    
      def close        
        @ssh.close
        # @sftp.close not needed
        @ssh, @sftp = nil
      end
      
      
      # 
      # File & Dir
      # 
      def exist? path
        begin
          fattrs = sftp.stat! fix_path(path)
          fattrs.directory? or fattrs.file? or fattrs.symlink?
        rescue Net::SFTP::StatusException
          false
        end
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
      
      def write_file path, &block        
        sftp.file.open fix_path(path), 'w' do |os|
          callback = -> buff {os.write buff}
          block.call callback
        end
      end   

      def file_exist? path
        begin
          fattrs = sftp.stat! fix_path(path)
          fattrs.file? or fattrs.symlink?
        rescue Net::SFTP::StatusException
          false
        end
      end

      def remove_file remote_file_path
        sftp.remove! fix_path(remote_file_path)
      end
      
      
      # 
      # Dir
      # 
      def create_directory path
        sftp.mkdir! path
      end
    
      def remove_directory path
        exec "rm -r #{path}"
      end
      
      def directory_exist? path
        begin
          fattrs = sftp.stat! fix_path(path)
          fattrs.directory? or fattrs.symlink?
        rescue Net::SFTP::StatusException
          false
        end
      end
      
      
      # 
      # Special
      # 
      def upload_directory from_local_path, to_remote_path
        sftp.upload! from_local_path, fix_path(to_remote_path)
      end
      
      def download_directory from_remote_path, to_local_path
        sftp.download! fix_path(from_remote_path), to_local_path, :recursive => true
      end
      
      
      # 
      # Shell
      # 
      def exec command
        # somehow net-ssh doesn't executes ~/.profile, so we need to execute it manually
        # command = ". ~/.profile && #{command}"

        stdout, stderr, code, signal = hacked_exec! ssh, command

        return code, stdout, stderr
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
        def hacked_exec!(ssh, command, &block)
          stdout_data = ""
          stderr_data = ""
          exit_code = nil
          exit_signal = nil
        
          channel = ssh.open_channel do |channel|
            channel.exec(command) do |ch, success|
              raise "could not execute command: #{command.inspect}" unless success

              channel.on_data{|ch2, data| stdout_data << data}
              channel.on_extended_data{|ch2, type, data| stderr_data << data}
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