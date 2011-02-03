require 'spec_helper'

shared_examples_for 'abstract driver' do
  dir = "#{File.dirname __FILE__}/abstract_driver"
  with_tmp_spec_dir dir, before: :each
  
  describe "io" do
    before :each do
      @local_dir = spec_dir      
      @remote_dir = @driver.generate_tmp_dir_name    
      
      @driver.remove_directory @remote_dir if @driver.directory_exist? @remote_dir
      @driver.create_directory @remote_dir
    end

    after :each do
      @driver.remove_directory @remote_dir if @driver.directory_exist? @remote_dir
    end
    
    def should_exist path, universal, file, dir
      @driver.exist?(path).should == universal
      @driver.file_exist?(path).should == file
      @driver.directory_exist?(path).should == dir
    end
  
    describe "files" do  
      def upload_file from_local, to_remote
        File.open from_local, 'r' do |from|
          @driver.write_file to_remote do |writer|
            writer.call from.gets
          end
        end
      end      
      
      before :each do
        @local_file = "#{@local_dir}/local_file"
        @check_file = "#{@local_dir}/check_file"
        @remote_file = "#{@remote_dir}/remote_file"
      end
            
      it "file_exist?" do
        should_exist @remote_file, false, false, false
        upload_file(@local_file, @remote_file)
        should_exist @remote_file, true, true, false
      end

      it "upload & download file" do
        upload_file @local_file, @remote_file
        @driver.file_exist?(@remote_file).should be_true
          
        File.open @check_file, 'w' do |to|
          @driver.read_file @remote_file do |buff|             
            to.write buff
          end
        end   
        File.read(@check_file).should == File.read(@local_file)
      end
    
      it "remove_file" do
        upload_file @local_file, @remote_file
        @driver.file_exist?(@remote_file).should be_true
        @driver.remove_file(@remote_file)
        @driver.file_exist?(@remote_file).should be_false
      end
    end
    
    describe 'directories' do
      before :each do
        @from_local, @remote_path, @to_local = "#{@local_dir}/dir", "#{@remote_dir}/upload", "#{@local_dir}/download"
      end
      
      it "directory_exist?, create_directory, remove_directory" do
        dir = "#{@remote_dir}/some_dir"
        should_exist dir, false, false, false
        @driver.create_directory(dir)
        should_exist dir, true, false, true
        @driver.remove_directory(dir)
        should_exist dir, false, false, false
      end
    
      it "upload_directory & download_directory" do
        upload_path_check = "#{@remote_path}/dir2/file"
        @driver.file_exist?(upload_path_check).should be_false
        @driver.upload_directory(@from_local, @remote_path)
        @driver.file_exist?(upload_path_check).should be_true

        download_path_check = "#{@to_local}/dir2/file"
        File.exist?(download_path_check).should be_false
        @driver.download_directory(@remote_path, @to_local)
        File.exist?(download_path_check).should be_true
      end
    end  
  end
  
  describe "shell" do
    it 'exec' do
      @driver.exec("echo 'ok'").should == [0, "ok\n", ""]
    end  
  end
end