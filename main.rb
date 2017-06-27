#!/usr/bin/env ruby

# Load lib/ and src/ files
ROOT = File.dirname __FILE__
Dir["#{ROOT}/lib/*.rb"].each { |f| load f }
Dir["#{ROOT}/src/**/*.rb"].each { |f| load f }

# Store configuration file in a global hash
require 'yaml'
G = YAML.load_file "#{ROOT}/conf.yml"


Game.play
