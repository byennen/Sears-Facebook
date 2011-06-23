require 'bundler/setup'
require 'haml'
require 'sass'
require 'json'

require 'sinatra' unless defined?(Sinatra)
require "sinatra/reloader" if development?
require 'yaml' if development?

configure do
  # load models
  $LOAD_PATH.unshift("#{File.dirname(__FILE__)}/lib")
  Dir.glob("#{File.dirname(__FILE__)}/lib/*.rb") { |lib| require File.basename(lib, '.*') }
end
