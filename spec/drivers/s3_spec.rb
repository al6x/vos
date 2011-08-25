require 'drivers/spec_helper'

require 'aws' rescue LoadError

if defined? AWS
  require 'vos/drivers/s3'

  describe 'S3' do
    before :all do
      @storage = Vos::Drivers::S3.new(config[:s3][:driver], bucket: config[:s3][:bucket])
      @storage.open
    end
    after(:all){@storage.close}

    before{@storage._clear}
    after{@storage._clear}

    it_should_behave_like 'vfs storage basic'
    it_should_behave_like 'vfs storage attributes basic'
    it_should_behave_like 'vfs storage files'

    describe 'limited attributes' do
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

    describe 'limited tmp' do
      it "tmp dir" do
        @storage.tmp.should_not be_nil

        file_path = nil
        @storage.tmp do |tmp_dir|
          file_path = "#{tmp_dir}/file"
          @storage.write_file(file_path, false){|w| w.write 'something'}
        end
        file_path.should_not be_nil
        @storage.attributes(file_path).should be_nil
      end
    end

    describe 'limited dirs' do
      def create_s3_fake_dir dir
        @storage.write_file("#{dir}/file.txt", false){|w| w.write 'something'}
      end

      it "directory crud" do
        @storage.attributes('/dir').should be_nil

        create_s3_fake_dir('/dir')
        attrs = @storage.attributes('/dir')
        attrs[:file].should be_false
        attrs[:dir].should  be_true

        @storage.delete_dir('/dir')
        @storage.attributes('/dir').should be_nil
      end

      it 'should delete not-empty directories' do
        create_s3_fake_dir('/dir')
        create_s3_fake_dir('/dir/dir2')
        @storage.write_file('/dir/dir2/file', false){|w| w.write 'something'}
        @storage.attributes('/dir').should_not be_nil

        @storage.delete_dir('/dir')
        @storage.attributes('/dir').should be_nil
      end

      it 'each' do
        # -> {@storage.each_entry('/not_existing_dir', nil){|path, type| list[path] = type}}.should raise_error

        create_s3_fake_dir('/dir/dir2')
        @storage.write_file('/dir/file', false){|w| w.write 'something'}

        list = {}
        @storage.each_entry('/dir', nil){|path, type| list[path] = type}
        list.should == {'dir2' => :dir, 'file' => :file}
      end
    end
  end
else
  warn 'no aws library, specs will be skipped'
end