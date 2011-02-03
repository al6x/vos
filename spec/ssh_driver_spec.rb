require 'abstract_driver'
require 'yaml'

describe Vos::Drivers::Ssh do
  it_should_behave_like "abstract driver"    

  before :all do
    @driver = Vos::Drivers::Ssh.new config[:remote_driver]
    @driver.open
  end
  
  after :all do
    @driver.close
  end  
end