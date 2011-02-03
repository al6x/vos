require 'spec_helper'

describe Vos::Box do  
  before :each do
    @box = Vos::Box.new
  end
  
  describe "shell" do
    it 'bash' do
      @box.bash("echo 'ok'").should == "ok\n"
    end  
    
    it "exec" do
      @box.exec("echo 'ok'").should == [0, "ok\n", ""]
    end
  end
end