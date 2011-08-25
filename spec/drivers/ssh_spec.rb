require 'drivers/spec_helper'

describe Vos::Drivers::Ssh do
  before :all do
    @storage = @driver = Vos::Drivers::Ssh.new(config[:ssh_driver], '/vos_test')
    @driver.open
  end

  after :all do
    @driver.close
  end

  before do
    @driver._delete_root_dir
    @driver._create_root_dir
  end
  after{@driver._delete_root_dir}

  it_should_behave_like "vos driver"

  it_should_behave_like 'vfs storage basic'
  it_should_behave_like 'vfs storage attributes basic'
  it_should_behave_like 'vfs storage files'
  it_should_behave_like 'vfs storage dirs'
  it_should_behave_like 'vfs storage tmp dir'

  describe 'limited ssh attributes' do
    it "attributes for dirs" do
      @storage.create_dir('/dir')
      attrs = @storage.attributes('/dir')
      attrs[:file].should be_false
      attrs[:dir].should  be_true
      # attrs[:created_at].class.should == Time
      attrs[:updated_at].class.should == Time
      attrs.should_not include(:size)
    end

    it "attributes for files" do
      @storage.write_file('/file', false){|w| w.write 'something'}
      attrs = @storage.attributes('/file')
      attrs[:file].should be_true
      attrs[:dir].should  be_false
      # attrs[:created_at].class.should == Time
      attrs[:updated_at].class.should == Time
      attrs[:size].should == 9
    end
  end
end