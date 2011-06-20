require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../lib')
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../../bin')
require 'fileutils'
require 'rspec/expectations'

require 'aruba/api'

# Monkey patch aruba to filter out some stuff
#module Aruba::Api
#  alias _all_stdout all_stdout
#
#  def all_stdout
#    out = _all_stdout
#
#    # Remove absolute paths
#    out.gsub!(/#{Dir.pwd}\/tmp\/aruba/, '.')
#    # Make duration predictable
#    out.gsub!(/^\d+m\d+\.\d+s$/, '0m0.012s')
#    # Remove SimpleCov message
#    out.gsub!(/Coverage report generated for Cucumber Features to #{Dir.pwd}\/coverage.*\n$/, '')
#
#    out
#  end
#end

require 'aruba/cucumber'

Before do |scenario|
  @scenario = scenario

  # Make sure bin/cucumber runs with SimpleCov enabled
  set_env('SIMPLECOV', 'true')

  # Set a longer timeout for aruba
  @aruba_timeout_seconds = 5
end

Before('@glacial') do |scenario|
  @aruba_io_wait_seconds = 10
end

Before('@slow') do |scenario|
  @aruba_io_wait_seconds = 2
end