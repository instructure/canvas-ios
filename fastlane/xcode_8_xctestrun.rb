require 'fastlane'
require 'scan'

module Xcode8
  class << self
    # args :scheme - required
    def _xcodebuild(command_name, args)
      raise 'missing opts' unless args
      raise 'opts must be a hash' unless args.is_a?(Hash)

      workspace = args.fetch(:workspace, 'AllTheThings.xcworkspace ')
      scheme = args.fetch(:scheme)
      destination = args.fetch(:destination, 'platform=iOS Simulator,name=iPhone 6,OS=latest')
      derived_data = args.fetch(:derived_data, 'xctestrun')

      command = [
          'set -o pipefail &&',
          'xcodebuild',
          "-workspace #{workspace}",
          "-scheme #{scheme}",
          "-destination '#{destination}'",
          "-derivedDataPath '#{derived_data}'",
          "#{command_name} | xcpretty"
      ].join(' ')

      Fastlane::Actions.execute_action(command_name) do
        Dir.chdir(File.join(__dir__, '..')) do # 'fastlane' is the default cwd. change to parent dir.
          FastlaneCore::CommandExecutor.execute(command: command,
                                                print_all: true,
                                                print_command: true,
                                                error: proc do |output|
                                                  ::Scan::ErrorHandler.handle_build_error(output)
                                                end)
        end # Dir.chdir
      end # execute_action
    end # def _xcodebuild

    # Executes xcodebuild build-for-testing
    def build_for_testing(args)
      _xcodebuild('build-for-testing', args)
    end

    # Executes xcodebuild test-without-building
    def test_without_building(args)
      _xcodebuild('test-without-building', args)
    end
  end # class << self
end # module Xcode 8
