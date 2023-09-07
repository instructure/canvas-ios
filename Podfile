source 'https://github.com/CocoaPods/Specs.git'

workspace 'Canvas.xcworkspace'
inhibit_all_warnings!
platform :ios, '15.0'
require_relative './rn/Teacher/node_modules/react-native/scripts/react_native_pods'
# require_relative './rn/Teacher/node_modules/@react-native-community/cli-platform-ios/native_modules'

def firebase_pods
  pod 'GoogleUtilities', '~> 7.6'
  pod 'Firebase/Crashlytics', '~> 8.12.1'
  pod 'Firebase/RemoteConfig', '~> 8.12.1'
  pod 'Firebase/Analytics', '~> 8.12.1'
end

def canvas_crashlytics_rn_firebase_pods
  pod 'GoogleUtilities', '~> 7.6'
  pod 'Firebase/Crashlytics', '~> 8.12.1'
end

def pspdfkit
  pod 'PSPDFKit', podspec: 'https://customers.pspdfkit.com/pspdfkit-ios/12.3.0.podspec'
end

def react_native_pods
  use_react_native!(:path => './rn/Teacher/node_modules/react-native')

  # node modules
  # use_native_modules!
  pod 'BVLinearGradient', :path => './rn/Teacher/node_modules/react-native-linear-gradient'
  pod 'Interactable', :path => './rn/Teacher/node_modules/react-native-interactable'
  pod 'react-native-camera', :path => './rn/Teacher/node_modules/react-native-camera'
  pod 'react-native-document-picker', :path => './rn/Teacher/node_modules/react-native-document-picker'
  pod 'react-native-image-picker', :path => './rn/Teacher/node_modules/react-native-image-picker'
  pod 'react-native-segmented-control', :path => './rn/Teacher/node_modules/@react-native-community/segmented-control'
  pod 'ReactNativeART', :path => './rn/Teacher/node_modules/@react-native-community/art'
  pod 'RNAudio', :path => './rn/Teacher/node_modules/react-native-audio'
  pod 'RNCAsyncStorage', :path => './rn/Teacher/node_modules/@react-native-community/async-storage'
  pod 'RNCPicker', :path => './rn/Teacher/node_modules/@react-native-community/picker'
  pod 'RNDateTimePicker', :path => './rn/Teacher/node_modules/@react-native-community/datetimepicker'
  pod 'RNFS', :path => './rn/Teacher/node_modules/react-native-fs'
  pod 'RNSearchBar', :path => './rn/Teacher/node_modules/react-native-search-bar'
  pod 'RNSound', :path => './rn/Teacher/node_modules/react-native-sound'
end

abstract_target 'needs-pspdfkit' do
  use_frameworks!
  pspdfkit
  target 'StudentE2ETests' do project 'Student/Student.xcodeproj' end
  target 'TeacherE2ETests' do project 'rn/Teacher/ios/Teacher.xcodeproj' end
  target 'ParentE2ETests' do project 'Parent/Parent.xcodeproj' end
end

abstract_target 'defaults' do
  use_frameworks!

  react_native_pods
  pspdfkit

  target 'Teacher' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    firebase_pods
  end

  target 'TeacherTests' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    firebase_pods
  end

  target 'Student' do
    project 'Student/Student.xcodeproj'
    firebase_pods
  end

  target 'StudentUnitTests' do
    project 'Student/Student.xcodeproj'
    firebase_pods
  end

  target 'CanvasCore' do
    project 'CanvasCore/CanvasCore.xcodeproj'
    canvas_crashlytics_rn_firebase_pods
  end
end

abstract_target 'parent_defaults' do
  use_frameworks!

  pspdfkit
  firebase_pods

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
  end

  target 'ParentUnitTests' do
    project 'Parent/Parent.xcodeproj'
  end
end

pre_install do |installer|
  # dSYMs cause problems, will be fixed in cocoapods 1.10
  # https://github.com/CocoaPods/CocoaPods/pull/9547
  installer.pod_targets.detect { |s| s.name == "PSPDFKit" }.framework_paths["PSPDFKit/Core"].map! do |framework_paths|
    Xcode::FrameworkPaths.new(framework_paths.source_path)
  end
end

post_install do |installer|
  puts "\nPost Install Hooks"
  
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
