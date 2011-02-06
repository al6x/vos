require 'spec_helper'

describe Vos::Box do  
  before :each do
    @box = Vos::Box.new
    @box.stub :puts
  end
  
  describe 'vfs' do
    it 'smoke test' do
      @box.open_fs #['/'].exist?.should be_true
    end
  end
  
  describe "shell" do
    it 'bash' do
      @box.bash("echo 'ok'").should == "ok\n"
    end  
    
    it 'check with regex' do
      @box.bash "echo 'ok'", /ok/
      -> {@box.bash "echo 'ok'", /no/}.should raise_error(/not match/)
    end
    
    it "exec" do
      @box.exec("echo 'ok'").should == [0, "ok\n", ""]
    end
  end
end