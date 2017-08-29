require 'xcodeproj'
require 'fileutils'
require 'plist'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: open_source_export.rb [options]'

  opts.on('-s', '--skip-copy', 'Skips copying over all of the files.') do |v|
    options[:skip_copy] = v
  end

  opts.on('-g', '--skip-git-clean', 'Skips doing a git clean before export.') do |v|
    options[:skip_clean] = v
  end
end.parse!

workspace_name = 'AllTheThings.xcworkspace'

# Quick check to make sure this script is run in the right place
raise "This script must be run from the same directory that contains #{workspace_name}" unless File.exist?(workspace_name)

unless options[:skip_clean]
  puts "Warning: this will remove any uncommitted code. Press any key to continue."
  gets

  # Export from develop. Remove files not tracked in git.
  ['git checkout develop', 'git clean -dfx', 'git reset --hard'].each do |command|
    raise "command failed: #{command}" unless system(command)
  end
end

targets = [workspace_name,
           'Canvas',
           'Parent',
           'rn',
           'Cartfile',
           'Cartfile.resolved',
           'Frameworks',
           'Podfile',
           'Podfile.lock',
           'ExternalFrameworks',
           'secrets.plist',
           '.gitignore',
           'fastlane',
           'Tinker.playground'
           'setup.sh']

destination          = 'ios-open-source'
frameworks_path      = File.join(destination, 'Frameworks')
workspace_path       = File.join(destination, workspace_name)

# The groups in the workspace that shouldn't be included
groups_to_remove     = %w[]

# Frameworks that should be removed as well
frameworks_to_remove = %w[DoNotShipThis SoAutomated EverythingBagel]

# Create a copy of all the required files and folders
unless options[:skip_copy]
  FileUtils.rm_r destination if File.exists? destination
  FileUtils.mkdir destination

  targets.each do |file|
    FileUtils.cp_r file, File.join(destination, file) if File.directory? file
    FileUtils.cp file, File.join(destination, file) unless File.directory? file
  end
end

workspace     = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
workspace_xml = workspace.document

# Goes through all the groups and all of the files and removes anything that shouldn't be there
workspace_xml.elements.each do |root|
  root.elements.each do |element|
    name = element.attribute('name').to_s
    root.delete element if groups_to_remove.any? { |file| file == name }
    element.elements.each do |child|
      location = child.attribute('location').to_s
      element.delete child if frameworks_to_remove.any? { |file| location.include?(file) }
    end
  end
end

# Package up the new workspace and peace out
fixed_workspace = Xcodeproj::Workspace.from_s(workspace_xml.to_s, workspace_path)
raise 'error creating fixed up workspace' unless fixed_workspace
fixed_workspace.save_as(workspace_path)

# Remove Fabric build scripts
def remove_fabric_from_project(project_path)
  project = Xcodeproj::Project.open(project_path)
  project.targets.each do |target|
    fabric_phase = target.shell_script_build_phases.detect { |phase| phase.name == "Fabric" }
    target.build_phases.delete(fabric_phase) if fabric_phase
  end
  project.save if project.dirty?
end

remove_fabric_from_project File.join(destination, 'Canvas', 'Canvas.xcodeproj')
remove_fabric_from_project File.join(destination, 'rn', 'Teacher', 'ios', 'Teacher.xcodeproj')

# Remove stuff from the Info.plist files
def remove_fabric_from_plist(plist_path)
  hash = Plist::parse_xml(plist_path)
  hash.delete 'Fabric'
  File.write(plist_path, hash.to_plist)
end

def prune_plist(plist_path)
  keys_hash = Plist::parse_xml(plist_path)
  keys_hash.each { |key, value| keys_hash[key] = '' }
  File.write(plist_path, keys_hash.to_plist)
end

def purge_plist(plist_path)
  keys_hash = Plist::parse_xml(plist_path)
  keys_hash.each { |key, value| keys_hash.delete key }
  File.write(plist_path, keys_hash.to_plist)
end

remove_fabric_from_plist File.join(destination, 'Canvas', 'Canvas', 'Info.plist')
remove_fabric_from_plist File.join(destination, 'rn', 'Teacher', 'ios', 'Teacher', 'Info.plist')

# Strip out all of the keys from our stuff, making an empty template file
prune_plist File.join(destination, 'secrets.plist')
prune_plist File.join(frameworks_path, 'Secrets', 'Secrets', 'feature_toggles.plist')

opensource_files_dir    = File.join('opensource', 'files')
external_frameworks_dir = File.join(destination, 'ExternalFrameworks')

# Copy over the readme files
FileUtils.cp File.join(opensource_files_dir, 'README.md'), File.join(destination, 'README.md')
FileUtils.mkdir external_frameworks_dir unless File.exist? external_frameworks_dir
FileUtils.cp File.join(opensource_files_dir, 'EFREADME.md'), File.join(external_frameworks_dir, 'README.md')

# Remove PSPDFKit from ExternalFrameworks
pspdfkit_dir = File.join(external_frameworks_dir, 'PSPDFKit.framework')
FileUtils.rm_r pspdfkit_dir if File.exists? pspdfkit_dir

# Remove GoogleServices plist
google_services_path = File.join(destination, 'Canvas', 'Canvas', 'Shrug', 'GoogleService-Info.plist')
purge_plist google_services_path

# Remove Matchfile
FileUtils.rm File.join(destination, 'fastlane', 'Matchfile')
FileUtils.rm File.join(destination, 'fastlane', 'Appfile')

# Remove buddybuild scripts
FileUtils.rm File.join(destination, 'rn', 'Teacher', 'ios', 'buddybuild_postbuild.sh')
FileUtils.rm File.join(destination, 'rn', 'Teacher', 'ios', 'buddybuild_prebuild.sh')

# Remove folders from frameworks that shouldn't be there
frameworks_to_remove.each do |folder|
  FileUtils.rm_r File.join(frameworks_path, folder)
end

puts "PRAISE THE SUN IT'S FINISHED"
