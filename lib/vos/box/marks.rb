module Vos
  class Box
    module Marks
      def mark key              
        marks_dir.file(key).create
        marks_cache.clear
      end

      def has_mark? key
        marks_cache.include? key.to_s
      end
    
      def clear_marks
        marks_dir.destroy
        marks_cache.clear
      end
      
      def marks_dir
        dir "/etc/vos/marks"
      end
      
      protected
        def marks_cache
          @marks_cache ||= marks_dir.files.collect{|file| file.name}
        end
    end
  end
end