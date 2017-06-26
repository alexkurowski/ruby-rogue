#!/usr/bin/env ruby

ROOT = File.dirname __FILE__
Dir["#{ROOT}/lib/*.rb"].each { |f| load f }
Dir["#{ROOT}/src/**/*.rb"].each { |f| load f }

Game.new
