require 'drivers/spec_helper'

describe Vos::Drivers::Ssh do
  it_should_behave_like "vos driver"    
  it_should_behave_like "vfs storage"

  before :all do
    @storage = @driver = Vos::Drivers::Ssh.new(config[:ssh_driver])
    @driver.open
  end
  
  after :all do
    @driver.close
  end  
end