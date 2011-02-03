require 'abstract_driver'

describe Vos::Drivers::Local do
  it_should_behave_like "abstract driver"    
    
  before :each do
    @driver = Vos::Drivers::Local.new
  end
end