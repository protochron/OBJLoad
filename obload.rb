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

#ARGV.each do |file|
#    ob = ObjectLib::ObjectLoader.new(file)

 #   if options[:verbose]
 #       p "Vertices: #{ob.numVertices}, Faces: #{ob.numFaces} Matfle: #{ob.matfile}"
#    end
    #ob.output(options[:output]) if options[:output]
 #   options[:output].each {|o| ob.output if options[:output]}
#end

