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
    puts 'Importing everything from Transifex, this could take a while...'
    success = system('tx pull -a')
    raise 'tx pull -a failed because reasons' unless success
end

projects = projects.select { |project| project.fetch('name') == options[:project] } if options[:project]
raise 'no projects to import' unless projects.count > 0
projects.each do |project|

    project_file = project.fetch('location')
    name = project.fetch('name')
    folder = "translations/canvas-ios.en_#{name}xliff"
    
    Dir.glob("#{folder}/*.xlf") do |file|
        puts "Importing #{file} into #{project_file}"
        success = system(%Q(xcodebuild -importLocalizations -localizationPath "#{file}" -project "#{project_file}"))
        raise 'xcodebuild -exportLocalizations failed for some reason... :(' unless success 
    end
end
