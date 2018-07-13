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

  # Export from master. Remove files not tracked in git.
  ['git checkout master', 'git clean -dfx', 'git reset --hard'].each do |command|
    raise "command failed: #{command}" unless system(command)
  end
end

targets = [workspace_name,
           'CanvasCore',
           'Canvas',
           'Parent',
           'rn',
           'Frameworks',
           'Podfile',
           'Podfile.lock',
           'preload-account-info.plist',
           'ExternalFrameworks',
           'secrets.plist',
           '.gitignore',
           'setup.sh']

destination          = 'ios-open-source'
frameworks_path      = File.join(destination, 'Frameworks')
canvas_core_path     = File.join(destination, 'CanvasCore')
workspace_path       = File.join(destination, workspace_name)
podfile_path         = File.join(destination, 'Podfile')

# The groups in the workspace that shouldn't be included
groups_to_remove = %w[]

# Frameworks that should be removed as well
frameworks_to_remove = %w[]

puts "Copying all required files and folders"
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
puts "Pruning Xcode workspace"
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

# Package up the new workspace
fixed_workspace = Xcodeproj::Workspace.from_s(workspace_xml.to_s, workspace_path)
raise 'error creating fixed up workspace' unless fixed_workspace
fixed_workspace.save_as(workspace_path)

puts "Removing Fabric build scripts"
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

puts "Removing all sensitive data"
def remove_secrets_from_plist(plist_path)
  hash = Plist::parse_xml(plist_path)
  hash.delete 'Fabric'
  hash.delete 'BugsnagAPIKey'
  File.write(plist_path, hash.to_plist)
end

def prune_plist(plist_path)
  abort("File doesn't exist: #{plist_path}") unless File.exist?(plist_path)
  keys_hash = Plist::parse_xml(plist_path)
  keys_hash.each { |key, value| keys_hash[key] = '' }
  File.write(plist_path, keys_hash.to_plist)
end

def purge_plist(plist_path)
  keys_hash = Plist::parse_xml(plist_path)
  keys_hash.each { |key, value| keys_hash.delete key }
  File.write(plist_path, keys_hash.to_plist)
end

# Fabric.with([Crashlytics.self, Answers.self]) will crash with:
# reason: '[Fabric] Value of Info.plist key "Fabric" must be a NSDictionary.'
# To fix this, the AppDelegate is rewritten to comment out Fabric.
def remove_fabric_from_app_delegate(app_delegate_path)
  raise "File doesn't exist: #{app_delegate_path}" unless File.exist?(app_delegate_path)
  fabric_init = 'Fabric.with('
  app_delegate = File.read(app_delegate_path)
  app_delegate.sub!(fabric_init, "//#{fabric_init}")
  File.write(app_delegate_path, app_delegate)
end

remove_secrets_from_plist File.join(destination, 'Canvas', 'Canvas', 'Info.plist')
remove_secrets_from_plist File.join(destination, 'rn', 'Teacher', 'ios', 'Teacher', 'Info.plist')
remove_secrets_from_plist File.join(destination, 'Parent', 'Parent', 'Info.plist')

remove_fabric_from_app_delegate File.join(destination, 'Canvas/Canvas/CanvasAppDelegate.swift')
remove_fabric_from_app_delegate File.join(destination, 'rn/Teacher/ios/Teacher/AppDelegate.swift')
remove_fabric_from_app_delegate File.join(destination, 'Parent/Parent/ParentAppDelegate.swift')

# Strip out all of the keys from our stuff, making an empty template file
prune_plist File.join(destination, 'secrets.plist')
prune_plist File.join(canvas_core_path, 'CanvasCore', 'Secrets', 'feature_toggles.plist')

opensource_files_dir    = File.join('opensource', 'files')
external_frameworks_dir = File.join(destination, 'ExternalFrameworks')

# Copy over the readme file
FileUtils.cp File.join(opensource_files_dir, 'README.md'), File.join(destination, 'README.md')

# Remove GoogleServices plist
google_services_path = File.join(destination, 'Canvas', 'GoogleService-Info.plist')
purge_plist google_services_path

# Remove buddybuild scripts
FileUtils.rm File.join(destination, 'rn', 'Teacher', 'ios', 'buddybuild_postbuild.sh')
FileUtils.rm File.join(destination, 'rn', 'Teacher', 'ios', 'buddybuild_prebuild.sh')

# Remove folders from frameworks that shouldn't be there
frameworks_to_remove.each do |folder|
  FileUtils.rm_r File.join(frameworks_path, folder)
end

# Replace PSPDFKit stuff in Podfile
expires = Date.new(2018, 10, 1)
raise "Cannot update Podfile with the correct information. You need to renew the trial Podfile URL with PSPDFKit" unless expires > Date.today

podfile_contents = File.read(podfile_path)
pspdfkit_license = "8YzxfVzsGsqs4HKYsejmoeD6WEJ9ma"
raise "Cannot update the Podfile with the correct PSPDFKit license" unless podfile_contents.include?(pspdfkit_license)
podfile_contents.gsub!(pspdfkit_license, "TRIAL-x47r57c_x_ndkkTGJ8Un-fmB8EXXDom1r2FSyQhPZEx2i2uQGGBjZnzJTJ_az2BccXySgrFZK3AwksivROwULg")
raise "Prod license not removed! Check gsub pattern" if podfile_contents.include?(pspdfkit_license)

# Remove deep links, exempt domains, & dev domains
File.write(File.join(destination, 'rn', 'CanvasPlayground', 'deep-links.json'), "[]")

feature_flags_path = File.join(destination, 'rn', 'Teacher', 'src', 'common', 'feature-flags.js')
File.write(feature_flags_path, File.read(feature_flags_path).sub(/exemptDomains = \[[^\]]*\]/, "exemptDomains = []"))

account_domain_path = File.join(destination, 'Frameworks', 'CanvasKit', 'CanvasKit', 'Models', 'CKIAccountDomain.m')
File.write(account_domain_path, File.read(account_domain_path).sub(/devDomains = @\[[^\]]*\]/, "devDomains = @[]"))


puts "PRAISE THE SUN IT'S FINISHED"
