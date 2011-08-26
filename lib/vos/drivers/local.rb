require 'vfs/drivers/local'

module Vos
  module Drivers
    class Local < Vfs::Drivers::Local
      attr_accessor :box

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
      def host; 'localhost' end
    end
  end
end