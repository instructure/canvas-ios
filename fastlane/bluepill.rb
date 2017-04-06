class Bluepill

  #./fastlane/bluepill-v1.0.0/bluepill
  # -a ./xctestrun/Build/Products/Debug-iphonesimulator/Teacher.app
  # -s ./rn/Teacher/ios/Teacher.xcodeproj/xcshareddata/xcschemes/TeacherUITests.xcscheme
  # -o ./bluepill/
  # -r iOS 10.3

  attr_reader :workspace, :app_scheme, :test_scheme, :output_folder

  def initialize opts = {}
    @workspace   = opts.fetch :workspace
    @app_scheme  = opts.fetch :app_scheme
    @test_scheme = opts.fetch :test_scheme
    @output_folder = opts.fetch :output_folder, 'bluepill'
  end

  def bluepill
    @bluepill ||= join(__dir__, 'bluepill-v1.0.0', 'bluepill')
  end

  def run
    execute_action('Build app for testing') do
      Xcode8.build_for_testing(scheme: app_scheme, workspace: workspace)
    end

    execute_action('Bluepill') do
      bluepill_test = [
          bluepill,
          "-a ./xctestrun/Build/Products/Debug-iphonesimulator/#{app_scheme}.app",
          "-s ./rn/#{app_scheme}/ios/#{app_scheme}.xcodeproj/xcshareddata/xcschemes/#{test_scheme}.xcscheme",
          %Q(-o "./#{output_folder}/"),
          %Q(-r "iOS #{TEST_SIMULATOR.ios_version}"),
      ]

      _execute(command: bluepill_test)
    end
  end
end
