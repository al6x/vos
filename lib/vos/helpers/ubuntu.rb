module Vos
  module Helpers
    module Ubuntu
      def default_env
        {:DEBIAN_FRONTEND => 'noninteractive'}
      end
      def wrap_cmd env_str, cmd
        %(. #{env_file.path} && #{env_str}#{' && ' unless env_str.empty?}#{cmd})
      end
      
      def env_file
        file '/etc/profile' ## file '/etc/environment'
      end
      
      # def append_to_environment file, reload = true
      #   raise "#{file} must be an Entry" unless file.is_a? Vfs::Entry        
      #   
      #   env_ext = dir '/etc/profile_ext'
      #   
      #   remote_file = env_ext[file.name]
      #   file.copy_to! remote_file
      # 
      #   require_clause = "source #{remote_file.path}"
      #   env_file.append "\n#{require_clause}\n" unless env_file.content.include? require_clause
      #   
      #   reload_env if reload
      # end
      
      def reload_env
        bash ". #{env_file.path}"
      end
    end
  end
end

module Vfs
  class File
    def append_to_environment_of box, reload = true
      raise "#{box} must be an Vos::Box" unless file.is_a? Vos::Box        
      
      copy_to! box.dir('/etc/profile_ext').file(name)

      require_clause = "source #{remote_file.path}"
      box.env_file.append "\n#{require_clause}\n" unless env_file.content.include? require_clause
      
      box.reload_env if reload
    end
  end
end