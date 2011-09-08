require 'rspec_ext'
require 'ruby_ext'
require 'vos'

require 'vos/drivers/local'
require 'vos/drivers/ssh'
require 'vos/drivers/s3'

rspec do
  def config
    dir = File.dirname __FILE__
    config_file_path = "#{dir}/config.yml"
    raise "no config '#{config_file_path}'!" unless File.exist? config_file_path
    @config ||= YAML.load_file config_file_path
  end
end