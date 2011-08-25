require 'drivers/spec_helper'

describe Vos::Drivers::Local do
  it_should_behave_like "vos driver"
  it_should_behave_like 'vfs storage basic'
  it_should_behave_like 'vfs storage files'
  it_should_behave_like 'vfs storage dirs'

  before do
    @storage = @driver = Vos::Drivers::Local.new
  end
end