# frozen_string_literal: true
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'


enable :sessions
get('/') do
  puts("Hello world")
end
