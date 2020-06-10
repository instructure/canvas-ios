source 'https://github.com/CocoaPods/Specs.git'

workspace 'Canvas.xcworkspace'
inhibit_all_warnings!
platform :ios, '12.0'
# require_relative './rn/Teacher/node_modules/@react-native-community/cli-platform-ios/native_modules'


def firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.20.0'
  pod 'Firebase/RemoteConfig', '~> 6.20.0'
  pod 'Firebase/Analytics', '~> 6.20.0'
end

def canvas_crashlytics_rn_firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.20.0'
end

def react_native_pods
  pod 'FBLazyVector', :path => "./rn/Teacher/node_modules/react-native/Libraries/FBLazyVector"
  pod 'FBReactNativeSpec', :path => "./rn/Teacher/node_modules/react-native/Libraries/FBReactNativeSpec"
  pod 'RCTRequired', :path => "./rn/Teacher/node_modules/react-native/Libraries/RCTRequired"
  pod 'RCTTypeSafety', :path => "./rn/Teacher/node_modules/react-native/Libraries/TypeSafety"
  pod 'React', :path => './rn/Teacher/node_modules/react-native/'
  pod 'React-Core', :path => './rn/Teacher/node_modules/react-native/'
  pod 'React-CoreModules', :path => './rn/Teacher/node_modules/react-native/React/CoreModules'
  pod 'React-Core/DevSupport', :path => './rn/Teacher/node_modules/react-native/'
  pod 'React-RCTActionSheet', :path => './rn/Teacher/node_modules/react-native/Libraries/ActionSheetIOS'
  pod 'React-RCTAnimation', :path => './rn/Teacher/node_modules/react-native/Libraries/NativeAnimation'
  pod 'React-RCTBlob', :path => './rn/Teacher/node_modules/react-native/Libraries/Blob'
  pod 'React-RCTImage', :path => './rn/Teacher/node_modules/react-native/Libraries/Image'
  pod 'React-RCTLinking', :path => './rn/Teacher/node_modules/react-native/Libraries/LinkingIOS'
  pod 'React-RCTNetwork', :path => './rn/Teacher/node_modules/react-native/Libraries/Network'
  pod 'React-RCTPushNotification', :path => './rn/Teacher/node_modules/react-native/Libraries/PushNotificationIOS'
  pod 'React-RCTSettings', :path => './rn/Teacher/node_modules/react-native/Libraries/Settings'
  pod 'React-RCTText', :path => './rn/Teacher/node_modules/react-native/Libraries/Text'
  pod 'React-RCTVibration', :path => './rn/Teacher/node_modules/react-native/Libraries/Vibration'
  pod 'React-Core/RCTWebSocket', :path => './rn/Teacher/node_modules/react-native/'

  pod 'React-cxxreact', :path => './rn/Teacher/node_modules/react-native/ReactCommon/cxxreact'
  pod 'React-jsi', :path => './rn/Teacher/node_modules/react-native/ReactCommon/jsi'
  pod 'React-jsiexecutor', :path => './rn/Teacher/node_modules/react-native/ReactCommon/jsiexecutor'
  pod 'React-jsinspector', :path => './rn/Teacher/node_modules/react-native/ReactCommon/jsinspector'
  pod 'ReactCommon/callinvoker', :path => "./rn/Teacher/node_modules/react-native/ReactCommon"
  pod 'ReactCommon/turbomodule/core', :path => "./rn/Teacher/node_modules/react-native/ReactCommon"
  pod 'Yoga', :path => './rn/Teacher/node_modules/react-native/ReactCommon/yoga', :modular_headers => true

  pod 'DoubleConversion', :podspec => './rn/Teacher/node_modules/react-native/third-party-podspecs/DoubleConversion.podspec'
  pod 'glog', :podspec => './rn/Teacher/node_modules/react-native/third-party-podspecs/glog.podspec'
  pod 'Folly', :podspec => './rn/Teacher/node_modules/react-native/third-party-podspecs/Folly.podspec'

  # node modules
  # use_native_modules!
  pod 'BVLinearGradient', :path => './rn/Teacher/node_modules/react-native-linear-gradient'
  pod 'Interactable', :path => './rn/Teacher/node_modules/react-native-interactable'
  pod 'react-native-camera', :path => './rn/Teacher/node_modules/react-native-camera'
  pod 'react-native-document-picker', :path => './rn/Teacher/node_modules/react-native-document-picker'
  pod 'react-native-image-picker', :path => './rn/Teacher/node_modules/react-native-image-picker'
  pod 'ReactNativeART', :path => './rn/Teacher/node_modules/@react-native-community/art'
  pod 'RNAudio', :path => './rn/Teacher/node_modules/react-native-audio'
  pod 'RNCAsyncStorage', :path => './rn/Teacher/node_modules/@react-native-community/async-storage'
  pod 'RNFS', :path => './rn/Teacher/node_modules/react-native-fs'
  pod 'RNSearchBar', :path => './rn/Teacher/node_modules/react-native-search-bar'
  pod 'RNSound', :path => './rn/Teacher/node_modules/react-native-sound'
end

abstract_target 'defaults' do
  use_frameworks!

  react_native_pods

  pod 'Marshal', '~> 1.2.7'
  pod 'Cartography', '~> 3.1'
  pod 'GoogleUtilities', '~> 6.0'

  target 'PactTests' do
    project 'Core/Core.xcodeproj'
    pod 'PactConsumerSwift', :git => 'https://github.com/DiUS/pact-consumer-swift.git'
  end

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
    firebase_pods
  end

  target 'ParentUnitTests' do
    project 'Parent/Parent.xcodeproj'
    firebase_pods
  end

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
    pod 'lottie-ios', '~> 3.1.8'
  end
  
  target 'StudentUnitTests' do
    project 'Student/Student.xcodeproj'
    firebase_pods
    pod 'lottie-ios', '~> 3.1.8'
  end
  
  target 'CanvasCore' do
    project 'CanvasCore/CanvasCore.xcodeproj'
    canvas_crashlytics_rn_firebase_pods
  end
end

post_install do |installer|
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

  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
    usesNonAppExAPI = %w[
      react-native-camera
      React
      react-native-document-picker
      react-native-wkwebview
    ]
    next unless usesNonAppExAPI.include? target.name
    puts "*** Setting #{target.name} target to APPLICATION_EXTENSION_API_ONLY = NO ***"
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
end
