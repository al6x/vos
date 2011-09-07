require 'drivers/spec_helper'

describe Vos::Drivers::Ssh do
  before :all do
    @driver = @driver = Vos::Drivers::Ssh.new(config[:ssh_driver].merge(root: '/vos_test'))
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

  it_should_behave_like 'vfs driver basic'
  it_should_behave_like 'vfs driver attributes basic'
  it_should_behave_like 'vfs driver files'
  it_should_behave_like 'vfs driver dirs'
  it_should_behave_like 'vfs driver tmp dir'

  describe 'limited ssh attributes' do
    it "attributes for dirs" do
      @driver.create_dir('/dir')
      attrs = @driver.attributes('/dir')
      attrs[:file].should be_false
      attrs[:dir].should  be_true
      # attrs[:created_at].class.should == Time
      attrs[:updated_at].class.should == Time
      attrs.should_not include(:size)
    end

    it "attributes for files" do
      @driver.write_file('/file', false){|w| w.write 'something'}
      attrs = @driver.attributes('/file')
      attrs[:file].should be_true
      attrs[:dir].should  be_false
      # attrs[:created_at].class.should == Time
      attrs[:updated_at].class.should == Time
      attrs[:size].should == 9
    end
  end
end