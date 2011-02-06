shared_examples_for 'vos driver' do  
  describe "shell" do
    it 'exec' do
      @driver.open do |d|
        d.exec("echo 'ok'").should == [0, "ok\n", ""]
      end
    end  
    
    it 'bash' do
      @driver.open do |d|
        d.bash("echo 'ok'").should == [0, "ok\n"]
      end
    end
  end
end