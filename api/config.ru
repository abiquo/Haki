# -*- mode: ruby -*-

require 'rubygems'
require 'bundler/setup'
require 'rack/content_length'
require 'json'
require 'sinatra'
require 'sinatra/base'
require 'uuid'
Dir['./app/helpers/*.rb'].each {|f| require f}
Dir['./app/routes/*.rb'].each {|f| require f}


set :run, false
set :public_folder, './public'
set :views, './views'
set :environment, :production
#use Rack::ContentLength
run Rack::Cascade.new [TestsApp]
