require 'spec_helper'

describe Vos::Box do
  with_tmp_spec_dir

  before do
    driver = Vos::Drivers::Local.new spec_dir
    @box = Vos::Box.new driver
    @box.stub :puts
  end

  describe 'vfs integration' do
    it 'smoke test' do
      @box['/'].exist?.should be_true
    end

    it 'vfs integration' do
      @box['/'].bash("echo 'ok'").should == "ok\n"
    end
  end

  describe "shell" do
    it 'bash' do
      @box.bash("echo 'ok'").should == "ok\n"
    end

    it 'bash working dir should be /' do
      @box.bash('pwd').should == "/\n"
    end

    it 'check with regex' do
      @box.bash "echo 'ok'", /ok/
      -> {@box.bash "echo 'ok'", /no/}.should raise_error(/not match/)
    end

    it "exec" do
      @box.exec("echo 'ok'").should == [0, "ok\n", ""]
    end

    it 'home' do
      @box.home.should_not be_nil
    end

    it 'env' do
      @box.env.should == {}
      @box.env = {a: 'b'}

      @box.env c: 'd' do
        @box.env.should == {a: 'b', c: 'd'}
      end
      @box.env.should == {a: 'b'}

      @box.env(c: 'd')
      @box.env.should == {a: 'b', c: 'd'}

      @box.env('ls').should == "a=b c=d && ls"
    end
  end
end