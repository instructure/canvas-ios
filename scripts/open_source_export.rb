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
end.parse!

workspace_name = 'AllTheThings.xcworkspace'

# Quick check to make sure this script is run in the right place
raise "This script must be run from the same directory that contains #{workspace_name}" unless File.exist?(workspace_name)

targets = [workspace_name, 
           'Canvas', 
           'Cartfile',
           'Cartfile.resolved',
           'Frameworks',
           'Podfile',
           'Podfile.lock',
           'ExternalFrameworks',
           'SpeedGrader'] 

destination = 'ios-open-source'
workspace_path = File.join(destination, workspace_name)

# The groups in the workspace that shouldn't be included
groups_to_remove = %w[Teacher Parent]

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

workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
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
remove_fabric_from_project File.join(destination, 'SpeedGrader', 'SpeedGrader.xcodeproj')

# Remove stuff from the Info.plist files
def remove_plist_stuff(plist_path) 
    hash = Plist::parse_xml(plist_path)
    hash.delete 'Fabric'
    File.write(plist_path, hash.to_plist)
end

remove_plist_stuff File.join(destination, 'Canvas', 'Canvas', 'Info.plist')
remove_plist_stuff File.join(destination, 'SpeedGrader', 'SpeedGrader', 'SpeedGrader-Info.plist')

opensource_files_dir = File.join('opensource', 'files')
external_frameworks_dir = File.join(destination, 'ExternalFrameworks')

# Copy over the readme files
FileUtils.cp File.join(opensource_files_dir, 'README.md'), File.join(destination, 'README.md')
FileUtils.mkdir external_frameworks_dir unless File.exist? external_frameworks_dir 
FileUtils.cp File.join(opensource_files_dir, 'EFREADME.md'), File.join(external_frameworks_dir, 'README.md')

# Remove PSPDFKit from ExternalFrameworks
pspdfkit_dir = File.join(external_frameworks_dir, 'PSPDFKit.framework')
FileUtils.rm_r pspdfkit_dir if File.exists? pspdfkit_dir

puts "PRAISE THE SUN IT'S FINISHED"
