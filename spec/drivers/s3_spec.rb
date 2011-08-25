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

    it_should_behave_like 'vfs storage basic'
    it_should_behave_like 'vfs storage files'

    describe 'vfs storage s3 fake dirs' do
      before do
        @tmp_dir = @storage.open_fs{|fs| fs.tmp}
        @remote_dir = "#{@tmp_dir}/some_dir"
      end

      after do
        @storage.open_fs{|fs| fs.delete_dir @tmp_dir if fs.attributes(@tmp_dir)[:dir]}
      end

      def create_s3_dir fs, dir
        fs.write_file("#{dir}/file.txt", false){|w| w.write 'something'}
      end

      it "directory_exist?, create_dir, delete_dir" do
        @storage.open_fs do |fs|
          fs.attributes(@remote_dir).should == {file: false, dir: false}
          create_s3_dir fs, @remote_dir
          fs.attributes(@remote_dir).subset(:file, :dir).should == {file: false, dir: true}
          fs.delete_dir(@remote_dir)
          fs.attributes(@remote_dir).should == {file: false, dir: false}
        end
      end

      it 'should delete not-empty directories' do
        @storage.open_fs do |fs|
          create_s3_dir fs, @remote_dir
          create_s3_dir fs, "#{@remote_dir}/dir"
          fs.write_file("#{@remote_dir}/dir/file", false){|w| w.write 'something'}
          fs.delete_dir(@remote_dir)
          fs.attributes(@remote_dir).should == {file: false, dir: false}
        end
      end

      it 'each' do
        @storage.open_fs do |fs|
          list = {}
          fs.each_entry(@tmp_dir, nil){|path, type| list[path] = type}
          list.should be_empty

          dir, file = "#{@tmp_dir}/dir", "#{@tmp_dir}/file"
          create_s3_dir fs, dir
          fs.write_file(file, false){|w| w.write 'something'}

          list = {}
          fs.each_entry(@tmp_dir, nil){|path, type| list[path] = type}
          list.should == {'dir' => :dir, 'file' => :file}
        end
      end
    end
  end
else
  warn 'no aws library, specs will be skipped'
end