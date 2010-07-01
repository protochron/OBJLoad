# Takes a .obj file and converts it into C++ OpenGL code.
# Good for taking objects created in a 3D app and natively rendering it in
#   OpenGL.
# Author::  Daniel Norris (mailto:dnorris10@gmail.com)
# Copyright:: Copyright (c) 2010 Daniel Norris
# License:: GPLv3 

require File.join(File.expand_path(File.dirname(__FILE__) + '/lib/objectLoader'))
require 'optparse'

#################################
# Construct command line options
#################################
options = {} #hash to hold options
optparse = OptionParser.new do |opts|
    #Banner
    opts.banner = "Usage: objectLoader.rb [options] file"

    #Verbose
    options[:verbose] = false
    opts.on('-v', '--verbose', 'Output full information') do
        options[:verbose] = true
    end

    #Output
    options[:output] 
    opts.on('-o', '--output FILE', 'Write OpenGL statements in C++ to FILE') do |file|
        options[:output] = file if !file.nil?
    end

    #Help screen
    opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit
    end
end

optparse.parse! #parse options and remove from ARGV

#Let the user know various modes are on
puts "Writing to #{options[:output]}" if options[:output] and options[:verbose]

######################
# Run Program
######################
file = ARGV[0]
ob = ObjectLib::ObjectLoader.new(file)
p "Vertices: #{ob.numVertices}, Faces: #{ob.numFaces} Matfle: #{ob.matfile}"if options[:verbose]

ob.output(options[:output]) if options[:output]
