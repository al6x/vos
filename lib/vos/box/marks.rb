module Vos
  class Box
    module Marks
      def mark key
        ensure_mark_requrements!
        file("#{marks_dir}/#{key}").create!
      end

      def has_mark? key
        ensure_mark_requrements!
        entry["#{marks_dir}/#{key}"].exist?
      end
    
      def clear_marks
        bash "rm -r #{marks_dir}"
      end
    
      protected
        def marks_dir
          home "/.marks"
        end

        def ensure_mark_requrements!
          unless @ensure_mark_requrements
            self.dir(marks_dir).create
            @ensure_mark_requrements = true
          end
        end
    end
  end
end