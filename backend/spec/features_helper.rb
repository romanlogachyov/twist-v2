# Require this file for feature tests
require_relative './spec_helper'

require 'capybara'
require 'capybara/dsl'
require 'capybara/rspec'

Capybara.app_host = ENV['FRONTEND_APP_URL']
