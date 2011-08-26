raise 'ruby 1.9.2 or higher required!' if RUBY_VERSION < '1.9.2'

require 'vos/gems'

require 'open3'

require 'fileutils'
require 'net/ssh'
require 'net/sftp'

require 'vfs'

%w(
  drivers/local
  drivers/ssh_vfs_storage
  drivers/ssh

  box/shell
  box/marks
  box/vfs
  box

  helpers/ubuntu
).each{|f| require "vos/#{f}"}

unless $vos_dont_mess_with_global_namespace
  Box = Vos::Box
end