require 'net/ssh'
require 'net/sftp'

module Vos
  module Drivers
    class Ssh < Abstract      
      DEFAULT_OPTIONS = {
        config: true
      }
      
      def initialize options = {}
        super        
        raise ":host not provided!" unless options[:host]
        @options = DEFAULT_OPTIONS.merge options
        
        # config_options = Net::SSH.configuration_for(options[:host])
        # options = DEFAULT_OPTIONS.merge(config_options).merge options
        # raise ":user not provided (provide explicitly or in .ssh/config)!" unless options[:user]
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
            opt = self.options.clone
            host = opt.delete :host #] || raise('host not provided!')
            # user = options.delete(:user) || raise('user not provied!')

            @ssh = Net::SSH.start(host, nil, opt)
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


      # 
      # Vfs
      # 
      include SshVfsStorage
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
      
      
      # 
      # Micelaneous
      # 
      def to_s; options[:host] end
      def host; options[:host] end
      
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