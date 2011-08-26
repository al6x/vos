require 'drivers/spec_helper'

require 'aws' rescue LoadError

if defined? AWS
  require 'vos/drivers/s3'

  describe 'S3' do
    before :all do
      @driver = Vos::Drivers::S3.new(config[:s3][:driver], bucket: config[:s3][:bucket])
      @driver.open
    end
    after(:all){@driver.close}

    before{@driver._clear}
    after{@driver._clear}

    it_should_behave_like 'vfs driver basic'
    it_should_behave_like 'vfs driver attributes basic'
    it_should_behave_like 'vfs driver files'

    describe 'limited attributes' do
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

    describe 'limited tmp' do
      it "tmp dir" do
        @driver.tmp.should_not be_nil

        file_path = nil
        @driver.tmp do |tmp_dir|
          file_path = "#{tmp_dir}/file"
          @driver.write_file(file_path, false){|w| w.write 'something'}
        end
        file_path.should_not be_nil
        @driver.attributes(file_path).should be_nil
      end
    end

    describe 'limited dirs' do
      def create_s3_fake_dir dir
        @driver.write_file("#{dir}/file.txt", false){|w| w.write 'something'}
      end

      it "there's no directories, so it should always return false" do
        @driver.attributes('/dir').should be_nil
        @driver.write_file('/dir/file.txt', false){|w| w.write 'something'}
        @driver.attributes('/dir').should be_nil
      end

      it 'should delete not-empty directories' do
        @driver.write_file('/dir/dir2/file', false){|w| w.write 'something'}
        @driver.attributes('/dir/dir2/file').should_not be_nil

        @driver.delete_dir('/dir')
        @driver.attributes('/dir/dir2/file').should be_nil
      end

      it 'each' do
        # -> {@driver.each_entry('/not_existing_dir', nil){|path, type| list[path] = type}}.should raise_error

        @driver.write_file('/dir/file', false){|w| w.write 'something'}
        @driver.write_file('/dir/dir2/file', false){|w| w.write 'something'}
        @driver.write_file('/other_dir/file', false){|w| w.write 'something'}

        list = {}
        @driver.each_entry('/dir', nil){|path, type| list[path] = type}
        list.should == {'dir2' => :dir, 'file' => :file}
      end
    end
  end
else
  warn 'no aws library, specs will be skipped'
end