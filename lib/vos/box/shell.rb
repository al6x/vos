module Vos
  class Box
    module Shell    
      def bash cmd, *args      
        check = args.shift if args.first.is_a?(Regexp)
        options = args.last || {}

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
        open{driver.exec cmd}
      end
    
      # def home path = nil
      #   open do
      #     @home ||= bash('cd ~; pwd').gsub("\n", '')    
      #     "#{@home}#{path}"
      #   end
      # end    
    
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