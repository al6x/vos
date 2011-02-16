module Vos
  module Helpers
    module Ubuntu
      def default_env
        {:DEBIAN_FRONTEND => 'noninteractive'}
      end
      def wrap_cmd env_str, cmd
        %(source #{env_file.path} && #{env_str}#{' && ' unless env_str.empty?}#{cmd})
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
  class Entry
    def symlink_to entry, options = {}
      raise "invalid argument!" unless entry.is_a? Entry
      raise "can't use symlink ('#{self}' and '#{entry}' are on different storages)!" if self.storage != entry.storage
      raise "symlink target '' not exist!" unless entry.exist?
      storage.bash "ln -s#{'f' if options[:override]} #{entry.path} #{path}"
    end
    
    def symlink_to! entry
      symlink_to entry, override: true
    end
  end
  
  class Dir
    def rsync_to entry
      raise "invalid argument!" unless entry.is_a? Entry      
      raise "#{path} must be a Dir" unless dir?
      raise "#{entry.path} can't be a File!" if entry.file?
      
      if local? and !entry.local?
        Box.local.bash("rsync -e 'ssh' -al --delete --stats --progress #{path}/ root@#{entry.storage.host}:#{entry.path}")
      elsif entry.local? and !local?        
        Box.local.bash("rsync -e 'ssh' -al --delete --stats --progress root@#{storage.host}:#{path}/ #{entry.path}")
      else
        raise "invalid usage!"
      end
    end
  end
  
  class File
    def append_to_environment_of box, reload = true
      raise "#{box} must be an Vos::Box" unless box.is_a? Vos::Box        
      
      remote_file = box.dir('/etc/profile_ext').file(name)
      copy_to! remote_file

      require_clause = <<-BASH

# #{name}
source #{remote_file.path}
      BASH
            
      box.env_file.append require_clause unless box.env_file.content.include? require_clause
      
      box.reload_env if reload
    end
  end
end