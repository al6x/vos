raise 'ruby 1.9.2 or higher required!' if RUBY_VERSION < '1.9.2'

require 'vos/gems'

require 'open3'


%w(
  support

  drivers/abstract
  drivers/local
  drivers/ssh

  box/shell
  box/marks  
  box/vfs
  box
  
  helpers/ubuntu
).each{|f| require "vos/#{f}"}