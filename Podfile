source 'https://github.com/CocoaPods/Specs.git'

workspace 'Canvas.xcworkspace'
inhibit_all_warnings!
platform :ios, '16.0'

def firebase_pods
  pod 'GoogleUtilities', '~> 7.13'
  pod 'Firebase/Crashlytics', '~> 10.23.1'
  pod 'Firebase/RemoteConfig', '~> 10.23.1'
end

def canvas_crashlytics_rn_firebase_pods
  pod 'GoogleUtilities', '~> 7.13'
  pod 'Firebase/Crashlytics', '~> 10.23.1'
end

abstract_target 'defaults' do
  use_frameworks!

  # target 'Teacher' do
  #   project 'Teacher/Teacher.xcodeproj'
  #   # firebase_pods
  # end

  # target 'TeacherTests' do
  #   project 'Teacher/Teacher.xcodeproj'
  #   # firebase_pods
  # end

  # target 'Student' do
  #   project 'Student/Student.xcodeproj'
  #   # firebase_pods
  # end

  # target 'SubmitAssignment' do
  #   project 'Student/Student.xcodeproj'
  #   # firebase_pods
  # end

  # target 'StudentUnitTests' do
  #   project 'Student/Student.xcodeproj'
  #   # firebase_pods
  # end
  
end

abstract_target 'parent_defaults' do
  use_frameworks!

  firebase_pods

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
  end

  target 'ParentUnitTests' do
    project 'Parent/Parent.xcodeproj'
  end
end

post_install do |installer|
  puts "\nPost Install Hooks"
  xcode_base_version = `xcodebuild -version | grep 'Xcode' | awk '{print $2}' | cut -d . -f 1`

  installer.pod_targets.each do |target|
    silenceWarningsInUmbrellas = %w[ React-Core ]
    next unless silenceWarningsInUmbrellas.include? target.name

    target.umbrella_header_path.open("r+") do |file|
      contents = file.read()
      file.seek 0
      file.puts '_Pragma("clang diagnostic push")'
      file.puts '_Pragma("clang diagnostic ignored \"-Weverything\"")'
      file.puts contents
      file.puts '_Pragma("clang diagnostic pop")'
    end
  end

  # https://github.com/CocoaPods/CocoaPods/issues/11553
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
  end

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      config.build_settings.delete('IPHONEOS_DEPLOYMENT_TARGET')
      config.build_settings.delete('ONLY_ACTIVE_ARCH')
      # Remove ARCHS settings from Pods, let them inherit from workspace / https://github.com/CocoaPods/CocoaPods/issues/10189
      config.build_settings.delete 'ARCHS'
      # This was added to work around an Xcode 13.3 bug when deploying to iOS 14 devices. https://developer.apple.com/forums/thread/702028?answerId=708408022
      config.build_settings['OTHER_LDFLAGS'] = '$(inherited) -Xlinker -no_fixup_chains'
      # For xcode 15+ only
      if config.base_configuration_reference && Integer(xcode_base_version) >= 15
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end
    usesNonAppExAPI = %w[
      react-native-camera
      React
      react-native-document-picker
      react-native-wkwebview
    ]
    next unless usesNonAppExAPI.include? target.name
    puts "- Disable APPLICATION_EXTENSION_API_ONLY on #{target.name}"
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
  
  # Non-executable bundles shouldn't be code signed
  installer.pods_project.targets.each do |target|
    if target.respond_to?(:product_type) and target.product_type == "com.apple.product-type.bundle"
      target.build_configurations.each do |config|
        puts "- Disable CODE_SIGNING_ALLOWED on #{target} (#{config})"
        config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      end
    end
  end
  
  puts "\n"
end
