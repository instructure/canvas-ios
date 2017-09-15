require 'json'
require 'optparse'

unless File.exists? 'translations/projects.json'
    abort 'OH NO! projects.json cannot be found. Please run this script only from the root of the repository.'
end

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: import.rb [options]'

  opts.on('-s', '--skipPull', 'Skips pulling from transifex') do |v|
    options[:skipPull] = v
  end

  opts.on('-pPROJECT', '--project=PROJECT', 'Import only a specific project') do |p|
    options[:project] = p
  end

  opts.on('-l', '--list', 'List projects that can be imported') do |l|
    options[:list] = l
  end

end.parse!

json = IO.read('translations/projects.json', encoding:'utf-8')
projects = JSON.parse json

if options[:list]
    puts projects.map { |project| project.fetch('name') }
    abort
end

# Gets everything that's translated from Transifex
unless options[:skipPull]
    command = 'tx pull -af'
    if options[:project]
        command << "r canvas-ios.en_#{options[:project]}*"
    end
    puts 'Importing everything from Transifex, this could take a while...'
    success = system(command)
    raise 'tx pull failed because reasons' unless success
end

projects = projects.select { |project| project.fetch('name') == options[:project] } if options[:project]
raise 'no projects to import' unless projects.count > 0
projects.each do |project|
    project_file = project.fetch('location')
    name = project.fetch('name')
    is_json = project.fetch('json')
    if is_json
        Dir.glob("#{project_file}/*.json") do |file|
            next if file.include? "temp.json"

            success = system("mv #{file} #{project_file}/temp.json && touch #{file}")
            raise "Failed to make a copy of #{file}" unless success

            temp = File.open("#{project_file}/temp.json")
            output = File.open(file, 'a')
            temp.each_line do |line|
                message = line[/^\s*\"message\": \"(.*)\"$/, 1].to_s

                if message.length > 0
                    message.gsub!('\"', '"')
                    message.gsub!('"', '\"')
                    line = "\t\"message\": \"#{message}\""
                end
                output.puts line
            end
            system("rm #{project_file}/temp.json")
        end
    else
        folder = "translations/canvas-ios.en_#{name}xliff"

        Dir.glob("#{folder}/*.xlf") do |file|
            puts "Importing #{file} into #{project_file}"
            success = system(%Q(xcodebuild -importLocalizations -localizationPath "#{file}" -project "#{project_file}"))
            raise 'xcodebuild -importLocalizations failed for some reason... :(' unless success
        end
    end
end
