###########################################
# ObjectLoader
# Class to load .OBJ files and convert
#   to OpenGL objects in C++
#
#   Use: Call from command line
#       ruby objectLoader filename
##########################################


###################
# Class definition
###################
module ObjectLib
    class ObjectLoader
        attr_accessor :numVertices, :numFaces, :vertices, :faces, :normals, :texCoords, :file, :filename, :matfile, :name

        def initialize(file)
            #Initialize class variables
            @vertices = []
            @normals = []
            @faces = []
            @texCoords = []

            @filename = file #store filename in class 
            if File.exists?(@filename) and File.readable?(@filename)
                f = File.open(@filename,'r+')
                data = []; #array for storing data
                f.each_line{|line| data.push line} #push lines into data aray
                f.close
                @file = data
                @matfile = @file[1][7..@file[1].size].chomp
                s = @file[2]
                @name = s[2..s.size - 1].chomp #get object name
                s = @file[3] #on 4th line of Wings3D file...
                s1 = s[1..s.size - 1].split(', ')
                @numVertices = s1[0].split(' ')[0].to_i
                @numFaces = s1[1].split(' ')[0].to_i

                #Read in data
                data = @file[4..@file.size - 1]
                data.each do |line|
                    l = line.split(' ')
                    type = l[0]
                    l = l[1..l.size - 1]
                    if type == 'v'
                        @vertices.push(l)
                    elsif type == 'vt'
                        @texCoords.push(l)
                    elsif type == 'vn'
                        @normals.push(l)
                    elsif type == 'f'
                        @faces.push(l)
                    end
                end
            else
                p "Error opening or reading #{@filename}"
            end
        end

        #################################
        # Output
        # Reads in the .OBJ file, parses
        #   for coordinates and then
        #   writes to a C++ .h and .cpp
        #   file. 
        #################################
        def output(outFile)

            tex = self.texture

            #Write header file
            f = File.new("#{outFile}.h", "w+")
            f.puts "//#{outFile}.h"
            f.puts "#include <GL/glut.h>"
            f.puts "#ifndef #{outFile.upcase}\n#define #{outFile.upcase}"
            #f.puts "using namespace std;"
            #f.puts "void construct_#{@name}();"
            f.puts "void draw_#{@name}();"
            f.puts "#endif"
            f.close

            #cpp file
            f = File.new("#{outFile}.cpp", "w+")
            f.puts "#include \"#{outFile}.h\""

            #construct function:
=begin
            f.puts "void construct_#{@name}()\n{"
            f.puts "\tdouble #{@name}_vertices [#{@numVertices}][3] = {\n"
            s = ""
            @vertices.each do |v|
                s += "\t{#{v[0]},#{v[1]},#{v[2]}},\n"
            end
            s = s[0..s.size - 3]
            f.puts s + "\n\t};"

            f.puts "\tdouble #{@name}_normals [#{@numVertices}][3] = {\n"
            s = ""
            @normals.each do |n|
                s += "\t{#{n[0]},#{n[1]},#{n[2]}},\n"
            end
            s = s[0..s.size - 3]
            f.puts s + "\n\t};"

            if tex != 0 
                f.puts "\tdouble #{@name}_texcoords[#{tex}][2] = {\n"
                s = ""
                @texCoords.each do |t|
                    s+= "\t{#{t[0]},#{t[1]}},\n"
                end
                s = s[0..s.size - 3]
                f.puts s + "\n\t};"
            end

            f.puts "}\n" #end construct function
=end
            #Draw function:
            f.puts "void draw_#{@name}()\n{"
            s = ""
            @faces.each do |fa|
                faceSize = fa.size
                faces = fa
                #determine what type of poly to draw
                if faceSize == 4
                    s += "\tglBegin(GL_QUADS);\n" 
                elsif faceSize == 3
                    s += "\tglBegin(GL_TRIANGLES);\n"
                else
                    s += "\tglBegin(GL_POLYGON);\n"
                end

                #Iterate through faces and write vertex, normal and texture commands
                faces.each do |fs|
                  face = fs
                  if tex != 0
                    coords = fs.split("/")
                    text = @texCoords[coords[1].to_i - 1]
                    s += "\t\tglTexCoord2f("
                    text.each{|t| s += t.to_s + ", "}
                    s = s[0..s.size - 3] + ");\n"
                  else
                      coords = fs.split('//')
                  end

                  #Normals
                  if tex == 0
                      norm = @normals[coords[1].to_i - 1]
                  else
                      norm = @normals[coords[2].to_i - 1]
                  end
                  s += "\t\tglNormal3f("
                  norm.each {|n| s += n.to_s + ", "}
                  s = s[0..s.size - 3] + ");\n"                      

                  #Vertices
                  vert = @vertices[coords[0].to_i - 1]
                  s += "\t\tglVertex3f("
                  vert.each {|v| s += v.to_s + ", "}
                  s = s[0..s.size - 3] + ");\n"
                end
                s += "\tglEnd();\n" #end polygon
            end
            f.puts s

            f.puts"}" #end construct function
            f.close
        end
        ###########################
        # Parse .OBJ file to figure
        #  out if there are any UV
        #  coords.
        ###########################
        def texture
            t = 0
            @file.each do |line|
                l = line.split(' ')
                if(l[0] == 'vt')
                   t = t + 1 
                end
            end
            return t
        end
    end #end class
end #end module
