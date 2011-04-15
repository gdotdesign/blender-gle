#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'yaml'
require 'coffee-script'
require 'pathname'

load 'Site/include/packager.rb'

p = Packager.new("package.yml")
contents = p.build

cfile = File.new "Build/lattice-latest.coffee", "w"
cfile.write contents
afile = File.new "Build/lattice-latest.js", "w"
afile.write CoffeeScript.compile contents, :bare=>true

FileUtils.copy("Themes/Blender/theme.css","Build/Blender")
