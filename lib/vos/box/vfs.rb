module Vos
  class Box
    module Vfs
      def to_entry
        '/'.to_entry_on(self.driver)
      end

      def to_file
        to_entry.file
      end

      def to_dir
        to_entry.dir
      end

      # def [] path
      #   to_entry[path]
      # end
      # alias_method :/, :[]

      %w(
        entry dir file
        entries dirs files
        [] /
        tmp
      ).each do |m|
        script = <<-RUBY
          def #{m} *a, &b
            to_entry.#{m} *a, &b
          end
        RUBY
        eval script, binding, __FILE__, __LINE__
      end
    end
  end
end

module Vfs
  class Dir
    def bash cmd, *args
      driver.box.bash_without_path "cd #{path} && #{cmd}", *args
    end
  end
  
  class << self
    def default_driver
      ::Vos::Box.local.driver
    end
  end
end