require 'drivers/spec_helper'

describe Vos::Drivers::Local do
  with_tmp_spec_dir

  before do
    @storage = @driver = Vos::Drivers::Local.new(spec_dir)
  end

  it_should_behave_like "vos driver"

  it_should_behave_like 'vfs storage basic'
  it_should_behave_like 'vfs storage attributes basic'
  it_should_behave_like 'vfs storage files'
  it_should_behave_like 'vfs storage full attributes for files'
  it_should_behave_like 'vfs storage dirs'
  it_should_behave_like 'vfs storage full attributes for dirs'
  it_should_behave_like 'vfs storage query'
  it_should_behave_like 'vfs storage tmp dir'
end