shared_examples_for 'vos driver' do
  it 'should respond to :host' do
    @driver.host.should_not be_nil
  end

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