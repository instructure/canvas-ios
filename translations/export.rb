#
#   This script makes assumptions about the file structure
#       - This script should be in the 'translations' directory of the iOS mono repo
#       - There should be a folder called 'translations/source', which is where all the files will end up
#       - The transifex cli should be installed

require 'nokogiri'
require 'pathname'
require 'json'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: import.rb [options]'

  opts.on('-s', '--skipPush', 'Skips pushing file to transifex') do |v|
    options[:skipPush] = v
  end

  opts.on('-pPROJECT', '--project=PROJECT', 'Import only a specific project') do |p|
    options[:project] = p
  end

end.parse!

class ExportLocalizations

    def initialize projects
        @projects = projects
    end

    def extract_xliff(project)
        location = project.fetch('location')
        name = project.fetch('name')
        output_path = "translations/source/#{name}/"
        puts "Exporting #{name} at #{location} to #{output_path}"

        success = system(%Q(xcodebuild -exportLocalizations -project "#{location}" -localizationPath "#{output_path}"))
        raise 'xcodebuild -exportLocalizations failed for some reason... :(' unless success
        strip_unwanted_stuff "#{output_path}/en.xliff"
    end

    def extract_json(project)
        location = project.fetch('location')
        name = project.fetch('name')
        puts "Exporting #{name} to #{location}"
        Dir.chdir(location) {
            system('yarn extract-strings')
            success = system("mv en.json temp.json && touch en.json")
            input = File.open("temp.json")
            output = File.open("en.json", 'a')
            input.each_line do |line|
                message = line[/^\s*\"message\": \"(.*)\"$/, 1].to_s

                if message.length > 0
                    message.gsub!('\n', '')
                    line = "\t\t\"message\": \"#{message}\""
                end
                output.puts line
            end
            system("rm temp.json")
        }
    end

    def do_the_thing
        puts "Exporting #{@projects.count} projects..."
        @projects.each do |project|
            if project['json']
                self.extract_json(project)
            else
                self.extract_xliff(project)
            end
        end
    end

    # There are a lot of localization files that have Info.plist localized stuff, such as testing targets
    # That's completely useless to our translators. This function removes all of that stuff, yayaya!
    def strip_unwanted_stuff(path)
        doc = Nokogiri::XML(File.read(path), nil, 'UTF-8')

        doc.search('file').each do |node|
            original = node.attribute('original').value
            node.remove if original.include? 'Info.plist'
        end

        path = Pathname(path)
        fixed_file = File.join(path.dirname, 'en-complete.xliff')
        File.write(fixed_file, doc.to_xml)
    end
end

unless File.exists? 'translations/projects.json'
    abort 'OH NO! projects.json cannot be found. Please run this script only from the root of the repository.'
end

tx_version = `tx --version`
puts "Transifex cli version: #{tx_version}"
puts 'Exporting all localizations to /translations/source'

json = IO.read('translations/projects.json', encoding:'utf-8')
projects = JSON.parse json
projects = projects.select { |project| project.fetch('name') == options[:project] } if options[:project]

exporter = ExportLocalizations.new(projects)
exporter.do_the_thing

unless options[:skipPush]
    puts 'Pushing all source files to Transifex'
    command = 'tx push -s'

    if options[:project]
        command << " -r canvas-ios.en_#{options[:project]}*"
    end

    success = system(command)
    raise 'tx push -s failed miserable, this is such a sad turn of events' unless success
end

puts "Finished!"
