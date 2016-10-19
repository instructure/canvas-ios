require 'nokogiri'
require 'pathname'

directory = ARGV[0]

if directory == nil
    puts "Please specify a .xlf file or a directory that contains xlf files"
    exit(1)
end

files = []

if directory.end_with? ".xlf"
    files.push(directory)
else
    Dir.glob(directory + "/*.xlf") do |file|
        files.push(file) 
    end
end

files.each do |file|

    io = File.open(file, 'r:UTF-8')
    doc = Nokogiri::XML(io, nil, 'UTF-8')
    io.close

    doc.search('file').each do |node|
        original = node.attribute("original").value
        if original.include? "Info.plist"
            node.remove
        end
    end

    path = Pathname(file)
    fixed_directory = File.join(path.dirname, "fixed")
    Dir.mkdir fixed_directory unless File.exists?(fixed_directory)
    new_file = File.join(fixed_directory, path.basename)
    output = File.open(new_file, "w:UTF-8")
    output.write(doc.to_xml)
    output.close()
end

puts "Processed #{files.count} file(s)"
