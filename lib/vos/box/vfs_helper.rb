module Vos
  class Box
    module VfsHelper
      def open_fs &block
        open &block
      end
      
      def [] path
        '/'.to_fs_on(self)[path]
      end
      alias_method :/, :[]
    end
  end
end