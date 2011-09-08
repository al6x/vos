raise 'ruby 1.9.2 or higher required!' if RUBY_VERSION < '1.9.2'

require 'vos/gems'

require 'open3'

require 'fileutils'
require 'net/ssh'
require 'net/sftp'

require 'vfs'

%w(
  drivers/local

  box/shell
  box/marks
  box/vfs
  box

  helpers/ubuntu
).each{|f| require "vos/#{f}"}

# Vos::Drivers.class_eval do
#   autoload :SshVfsStorage, 'vos/drivers/ssh_vfs_storage'
#   autoload :Ssh,           'vos/drivers/ssh'
#
#   autoload :S3VfsStorage, 'vos/drivers/s3_vfs_storage'
#   autoload :S3,           'vos/drivers/s3'
# end

unless $vos_dont_mess_with_global_namespace
  Box = Vos::Box
end