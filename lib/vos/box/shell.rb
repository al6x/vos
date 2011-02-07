module Vos
  class Box
    module Shell                
      def bash cmd, *args
        self['/'].bash cmd, *args
      end
      
      def bash_without_path cmd, *args
        check = args.shift if args.first.is_a?(Regexp)
        options = args.last || {}

        cmd = env cmd
        code, stdout_and_stderr = open{driver.bash cmd}

        unless code == 0
          puts stdout_and_stderr
          raise "can't execute '#{cmd}'!" 
        end

        if check and (stdout_and_stderr !~ check)
          puts stdout_and_stderr
          raise "output not match with #{check.inspect}!"
        end

        stdout_and_stderr
      end
    
      def exec cmd
        open{driver.exec(env(cmd))}
      end
      
      attr_writer :env
      def env command_or_env_variables = nil, &block
        @env ||= default_env
        
        if block                    
          before = env.clone
          begin            
            if variables = command_or_env_variables
              raise 'invalid arguments' unless variables.is_a? Hash
              @env.merge! variables
            end
            block.call
          ensure
            @env = before
          end
        else
          if command_or_env_variables == nil
            @env
          elsif command_or_env_variables.is_a? String
            cmd = command_or_env_variables
            env_str = env.to_a.collect{|k, v| "#{k}=#{v}"}.join(' ')
            wrap_cmd env_str, cmd
          elsif command_or_env_variables.is_a? Hash
            variables = command_or_env_variables
            @env.merge! variables
          else
            raise 'invalid arguments'
          end
        end
      end      
      def default_env
        {}
      end
      def wrap_cmd env_str, cmd
        %(#{env_str}#{' && ' unless env_str.empty?}#{cmd})
      end
      
    
      def home path = nil
        open do
          @home ||= bash('cd ~; pwd').gsub("\n", '')    
          "#{@home}#{path}"
        end
      end    
    
      # def generate_tmp_dir_name
      #   open do
      #     driver.generate_tmp_dir_name
      #   end
      # end
    
      # def inspect
      #   "<Box: #{options[:host]}>"
      # end
      # alias_method :to_s, :inspect
    end
  end
end