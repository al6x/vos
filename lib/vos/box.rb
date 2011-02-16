module Vos
  class Box
    include Shell, Marks, Vfs
    
    def initialize *args
      first = args.first
      if args.empty?
        @driver = Drivers::Local.new
      elsif first.is_a?(String) or first.is_a?(Symbol) or first.is_a?(Hash) and (args.size <= 2)
        if first.is_a? Hash
          options = first
          options[:host] ||= 'localhost'
        else          
          options = args[1] || {}
          raise 'invalid arguments' unless options.is_a?(Hash)
          options[:host] = first.to_s
        end
        
        @driver = options[:host] == 'localhost' ? Drivers::Local.new : Drivers::Ssh.new(options)
      elsif args.size == 1
        @driver = first
      else
        raise 'invalid arguments'
      end
    end


    # 
    # driver
    # 
    attr_reader :driver
    
    def open &block
      driver.open &block
    end    
    def close
      driver.close
    end

    
    # 
    # Micelaneous
    # 
    def inspect; driver.to_s end
    alias_method :to_s, :inspect
    
    def host; driver.host end
    
    def local?; host == 'localhost' end
    
    class << self      
      def local; @local ||= Box.new end
    end
  end
end