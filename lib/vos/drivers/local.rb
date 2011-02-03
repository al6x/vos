module Vos
  module Drivers
    class Local < Abstract    
      DEFAULT_BUFFER = 1024*1024
      class << self
        attr_accessor :buffer
      end
      
      # 
      # Establishing channel
      # 
      def open; end    
      def close; end
      
      
      # 
      # File & Dir
      # 
      def exist? path
        File.exist? path
      end
      
      
      # 
      # File
      #       
      def read_file path, &block
        File.open path, 'r' do |is|
          while buff = is.gets(self.class.buffer || DEFAULT_BUFFER)            
            block.call buff
          end
        end
      end
      
      def write_file path, &block        
        File.open path, 'w' do |os|
          callback = -> buff {os.write buff}
          block.call callback
        end
      end
      
      def remove_file path
        File.delete path
      end
    
      def file_exist? path
        File.exist?(path) and !File.directory?(path)
      end
              
      
      # 
      # Dir
      #
      def create_directory path
        Dir.mkdir path
      end
    
      def remove_directory path
        FileUtils.rm_r path
      end
      
      def directory_exist? path
        File.exist?(path) and File.directory?(path)
      end
      
      
      # 
      # Special
      # 
      def upload_directory from_local_path, to_remote_path
        FileUtils.cp_r from_local_path, to_remote_path
      end
      
      def download_directory from_remote_path, to_local_path
        FileUtils.cp_r from_remote_path, to_local_path
      end


      # 
      # Shell
      # 
      def exec command        
        code, stdout, stderr = Open3.popen3 command do |stdin, stdout, stderr, waitth|  
          [waitth.value.to_i, stdout.read, stderr.read]
        end
      
        return code, stdout, stderr
      end
    end
  end
end