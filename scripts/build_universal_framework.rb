require 'optparse'
require 'fileutils'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: build_universal_framework.rb [options]'

  opts.on('-w', '--workspace WORKSPACE', 'Path to the xcworkspace') do |v|
    options[:workspace] = v
  end

  opts.on('-p', '--project PROJECT', 'Path to the xcodeproj') do |v|
    options[:project] = v
  end

  opts.on('-s', '--scheme SCHEME', 'The name of the scheme') do |v|
    options[:scheme] = v
  end

  opts.on('-t', '--target TARGET', 'The name of the target to build') do |v|
    options[:target] = v
  end

  opts.on('-o', '--output OUTPUT', 'The directory where the framework should be put') do |v|
    options[:output] = v
  end

  opts.on('-h', '--help', 'Show the help menu') do
    puts opts
    exit
  end
end.parse!

raise "This script must be run from the root directory of the repository" unless File.exist?("AllTheThings.xcworkspace")

@tmp_directory = File.absolute_path('tmp')

FileUtils.rm_r @tmp_directory if File.exists?(@tmp_directory)

def build_scheme(sdk, opts)
  command = "xcodebuild build"
  command += " -project #{opts[:project]}" unless opts[:project].nil?
  command += " -workspace #{opts[:workspace]}" unless opts[:workspace].nil?
  command += " -scheme #{opts[:scheme]}" unless opts[:scheme].nil?
  command += " -target #{opts[:target]}" unless opts[:target].nil?
  command += " -configuration Release"
  command += " -sdk #{sdk}"
  command += " BITCODE_GENERATION_MODE=bitcode"
  command += " SYMROOT=#{@tmp_directory}"
  command += " | xcpretty"
  system(command)
end

exit unless build_scheme('iphoneos', options)
exit unless build_scheme('iphonesimulator', options)

FileUtils.mkdir(options[:output]) unless File.exists?(options[:output])

framework_name = options[:scheme] || options[:target]

FileUtils.cp_r("#{@tmp_directory}/Release-iphoneos/#{framework_name}.framework", options[:output] )
FileUtils.cp_r("#{@tmp_directory}/Release-iphonesimulator/#{framework_name}.framework", options[:output]  )

device_framework_path = File.join(@tmp_directory, "Release-iphoneos", "#{framework_name}.framework", framework_name)
simulator_framework_path = File.join(@tmp_directory, "Release-iphonesimulator", "#{framework_name}.framework", framework_name)
universal_framework_path = File.join(options[:output] , "#{framework_name}.framework", framework_name)
dsym_path = File.join(options[:output]  , "#{framework_name}.framework.dSYM")

lipo = "lipo -create"
lipo += " \"#{device_framework_path}\""
lipo += " \"#{simulator_framework_path}\""
lipo += " -output \"#{universal_framework_path}\""
system(lipo)

dsym = "dsymutil \"#{universal_framework_path}\""
dsym += " --out #{dsym_path}"
system(dsym)
