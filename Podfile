source 'https://github.com/CocoaPods/Specs.git'

workspace 'AllTheThings.xcworkspace'
inhibit_all_warnings!
platform :ios, '11.0'

abstract_target 'defaults' do
  use_frameworks!

  nm_path = './rn/Teacher/node_modules/'
  rn_path = nm_path + 'react-native/'
  pod 'yoga', :path => rn_path + 'ReactCommon/yoga'
  pod 'React', :path => rn_path, :subspecs => [
    'Core',
    'ART',
    'RCTActionSheet',
    'RCTAnimation',
    'RCTImage',
    'RCTSettings',
    'RCTVibration',
    'RCTNetwork',
    'RCTText',
    'RCTWebSocket',
    'RCTPushNotification',
    'RCTLinkingIOS',
    'DevSupport',
    'BatchedBridge',
    'fishhook'
  ]

  # node modules
  pod 'RNFS', :path => nm_path + 'react-native-fs'
  pod 'react-native-blur', :path => nm_path + 'react-native-blur'
  pod 'RNDeviceInfo', :path => nm_path + 'react-native-device-info'
  pod 'react-native-image-picker', :path => nm_path + 'react-native-image-picker'
  pod 'Interactable', :path => nm_path + 'react-native-interactable'
  pod 'BVLinearGradient', :path => nm_path + 'react-native-linear-gradient'
  pod 'react-native-mail', :path => nm_path + 'react-native-mail'
  pod 'ReactNativeSearchBar', :path => nm_path + 'react-native-search-bar'
  pod 'RCTSFSafariViewController', :path => nm_path + 'react-native-sfsafariviewcontroller'
  pod 'react-native-document-picker', :path => nm_path + 'react-native-document-picker'
  pod 'RNAudio', :path => nm_path + 'react-native-audio'
  pod 'RCTSFSafariViewController', :path => nm_path + 'react-native-sfsafariviewcontroller'
  pod 'RNSound', :path => nm_path + 'react-native-sound'
  pod 'react-native-camera', :path => nm_path + 'react-native-camera'

  pod 'SDWebImage', '~> 4.1'
  pod 'ReactiveCocoa', '~> 8.0'
  pod 'Marshal', '~> 1.1'
  pod 'Result', '~> 4.1'
  pod 'Cartography', '~> 3.1'
  pod 'ReactiveSwift', '~> 4.0'
  pod 'Kingfisher', '~> 4.10'
  pod 'Masonry', '~> 1.0'
  pod 'SVProgressHUD', '~> 2.0'
  pod 'TBBModal', '~> 1.0'
  pod 'ReactiveObjC', '~> 3.1'
  pod 'ReactiveObjCBridge', '~> 4.0'
  pod 'AFNetworking', '~> 3.0'
  pod 'FXKeychain', '~> 1.5'
  pod 'Reachability', '~> 3.2'
  pod 'Mantle', '~> 1.5.5'
  pod 'DeviceKit', '~> 1.13'
  pod 'TPKeyboardAvoiding', '~> 1.3'
  pod 'SwiftSimplify'

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Eureka', '~> 4.3'
    pod 'Firebase/Core'
  end

  target 'Teacher' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core'
  end

  target 'TeacherTests' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core'
  end

  target 'TechDebt' do
    project 'Canvas/Canvas.xcodeproj'
    pod 'FXKeychain', '~> 1.5'
  end

  target 'Canvas' do
    project 'Canvas/Canvas.xcodeproj'
    pod 'Fabric', '~> 1.7.7'
    pod 'Firebase/Core'
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

target 'GradesWidget' do
    use_frameworks!

    project 'Canvas/Canvas.xcodeproj'
    pod 'Mantle', '~> 1.5.5'
    pod 'AFNetworking', '~> 3.0'
    pod 'ReactiveObjC', '~> 3.1'
    pod 'FXKeychain', '~> 1.5'
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
      react-native-mail
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
