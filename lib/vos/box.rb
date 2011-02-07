module Vos
  class Box
    include Shell, Marks, Vfs
    
    attr_accessor :options
    
    def initialize options = {}
      @options = options
      options[:host] ||= 'localhost'
    end


    # 
    # driver
    # 
    def driver
      unless @driver
        klass = options[:host] == 'localhost' ? Drivers::Local : Drivers::Ssh
        @driver = klass.new options
      end
      @driver
    end
    
    def open &block
      driver.open &block
    end    
    def close
      driver.close
    end

    
    # 
    # Micelaneous
    # 
    def inspect
      host = options[:host]
      if host == 'localhost'
        ''
      else
        host
      end
    end
    alias_method :to_s, :inspect
  end
end