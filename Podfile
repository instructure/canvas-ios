source 'https://github.com/CocoaPods/Specs.git'

workspace 'Canvas.xcworkspace'
inhibit_all_warnings!
platform :ios, '12.0'

def firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.20.0'
  pod 'Firebase/RemoteConfig', '~> 6.20.0'
  pod 'Firebase/Analytics', '~> 6.20.0'
end

def canvas_crashlytics_rn_firebase_pods
  pod 'Firebase/Crashlytics', '~> 6.20.0'
end

def pspdfkit
  pod 'PSPDFKit',
    podspec: 'https://customers.pspdfkit.com/cocoapods/rTqo6AXV42EZLAdXASrGZeckgKVbxZ/pspdfkit/latest.podspec'
end


abstract_target 'defaults' do
  use_frameworks!

  nm_path = './rn/Teacher/node_modules/'
  rn_path = nm_path + 'react-native/'
  pod 'React', :path => rn_path, :subspecs => [
    'Core',
    'CxxBridge', # Include this for RN >= 0.47
    'DevSupport', # Include this to enable In-App Devmenu if RN >= 0.43
    'RCTText',
    'RCTNetwork',
    'RCTWebSocket', # needed for debugging
    # Add any other subspecs you want to use in your project
    'ART',
    'RCTActionSheet',
    'RCTAnimation',
    'RCTImage',
    'RCTSettings',
    'RCTVibration',
    'RCTPushNotification',
    'RCTLinkingIOS',
    'fishhook'
  ]
  # Explicitly include Yoga if you are using RN >= 0.42.0
  pod "yoga", :path => rn_path + 'ReactCommon/yoga'

  # Third party deps podspec link
  pod 'DoubleConversion', :podspec => rn_path + 'third-party-podspecs/DoubleConversion.podspec'
  pod 'glog', :podspec => rn_path + 'third-party-podspecs/glog.podspec'
  pod 'Folly', :podspec => rn_path + 'third-party-podspecs/Folly.podspec'

  # node modules
  pod 'RNCAsyncStorage', :path => nm_path + '@react-native-community/async-storage'
  pod 'RNFS', :path => nm_path + 'react-native-fs'
  pod 'RNDeviceInfo', :path => nm_path + 'react-native-device-info'
  pod 'react-native-image-picker', :path => nm_path + 'react-native-image-picker'
  pod 'Interactable', :path => nm_path + 'react-native-interactable'
  pod 'BVLinearGradient', :path => nm_path + 'react-native-linear-gradient'
  pod 'RNSearchBar', :path => nm_path + 'react-native-search-bar'
  pod 'react-native-document-picker', :path => nm_path + 'react-native-document-picker'
  pod 'RNAudio', :path => nm_path + 'react-native-audio'
  pod 'RNSound', :path => nm_path + 'react-native-sound'
  pod 'react-native-camera', :path => nm_path + 'react-native-camera'

  pod 'Marshal', '~> 1.2.7'
  pod 'Cartography', '~> 3.1'
  pod 'GoogleUtilities', '~> 6.0'

  pspdfkit

  target 'Core' do
    project 'Core/Core.xcodeproj'
    pod 'PactConsumerSwift', :git => 'https://github.com/DiUS/pact-consumer-swift.git'
    pspdfkit
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

post_install do |installer|
  installer.pod_targets.each do |target|
    silenceWarningsInUmbrellas = %w[ React ]
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
