require 'vfs/storages/local'

module Vos
  module Drivers
    class Local
      def initialize root = ''
        @root = root
      end

      #
      # Vfs
      #
      include Vfs::Storages::Local::LocalVfsHelper
      def open &block
        block.call self if block
      end
      def close; end


      #
      # Shell
      #
      def exec command
        code, stdout, stderr = Open3.popen3 command do |stdin, stdout, stderr, waitth|
          [waitth.value.to_i, stdout.read, stderr.read]
        end

        return code, stdout, stderr
      end


      def bash command
        code, stdout_and_stderr = Open3.popen2e command do |stdin, stdout_and_stderr, wait_thread|
          [wait_thread.value.to_i, stdout_and_stderr.read]
        end

        return code, stdout_and_stderr
      end


      #
      # Other
      #
      def to_s; '' end
      def host; 'localhost' end
    end
  end
end