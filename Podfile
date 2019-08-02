source 'https://github.com/CocoaPods/Specs.git'

workspace 'AllTheThings.xcworkspace'
inhibit_all_warnings!
platform :ios, '11.0'

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
  pod 'ReactNativeSearchBar', :path => nm_path + 'react-native-search-bar'
  pod 'RCTSFSafariViewController', :path => nm_path + 'react-native-sfsafariviewcontroller'
  pod 'react-native-document-picker', :path => nm_path + 'react-native-document-picker'
  pod 'RNAudio', :path => nm_path + 'react-native-audio'
  pod 'RNSound', :path => nm_path + 'react-native-sound'
  pod 'react-native-camera', :path => nm_path + 'react-native-camera'

  pod 'Marshal', '~> 1.2.7'
  pod 'Cartography', '~> 3.1'
  pod 'Kingfisher', '~> 4.10'
  pod 'SVProgressHUD', '~> 2.0'
  pod 'TBBModal', '~> 1.0'
  pod 'AFNetworking', '~> 3.0'
  pod 'Mantle', '~> 1.5.5'

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Eureka', '~> 4.3'
    pod 'Firebase/Core', '~> 5.20'
  end

  target 'Teacher' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core', '~> 5.20'
  end

  target 'TeacherTests' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core', '~> 5.20'
  end

  target 'TechDebt' do
    project 'Canvas/Canvas.xcodeproj'
  end

  target 'Canvas' do
    project 'Canvas/Canvas.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core', '~> 5.20'
  end

  target 'CanvasCore' do
    project 'CanvasCore/CanvasCore.xcodeproj'
    pod 'Crashlytics', '~> 3.10.2'
  end

  target 'CanvasKit1' do
    project 'Canvas/Canvas.xcodeproj'
  end

  target 'CanvasKit' do
    project 'Frameworks/CanvasKit/CanvasKit.xcodeproj'
  end

  target 'CanvasKeymaster' do
    project 'Frameworks/CanvasKeymaster/CanvasKeymaster.xcodeproj'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
    usesNonAppExAPI = %w[
      SVProgressHUD
      RCTSFSafariViewController
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
