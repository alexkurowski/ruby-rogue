#!/usr/bin/env ruby

# Load lib/ and src/ files
ROOT = File.dirname __FILE__
Dir["#{ROOT}/lib/*.rb"].each { |f| load f }
Dir["#{ROOT}/src/**/*.rb"].sort_by { |path| path.count '/' }.each { |f| load f }


# Store configuration file in a global hash
require 'yaml'
CONFIG   = YAML.load_file "#{ROOT}/config/config.yml"
TILES    = YAML.load_file "#{ROOT}/config/tiles.yml"
PREFABS  = YAML.load_file "#{ROOT}/config/prefabs.yml"


Game.play
