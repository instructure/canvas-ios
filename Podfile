source 'git@github.com:instructure/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AllTheThings.xcworkspace'
inhibit_all_warnings!
platform :ios, '10.0'

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
  pod 'BugsnagReactNative', :path => nm_path + 'bugsnag-react-native'

  pod 'SDWebImage', '~> 4.1'
  pod 'SVGKit', :git => 'https://github.com/SVGKit/SVGKit.git', :branch => '2.x'
  pod 'ReactiveCocoa', '~> 5.0'
  pod 'Marshal', '~> 1.1'
  pod 'Result', '~> 3.2'
  pod 'Cartography', '~> 1.1'
  pod 'ReactiveSwift'
  pod 'Kingfisher', '~> 3.2'
  pod 'JSTokenField', '~> 1.1'
  pod 'CocoaLumberjack', '~> 3.0'
  pod 'Masonry', '~> 1.0'
  pod 'SVProgressHUD', '~> 2.0'
  pod 'TBBModal', '~> 1.0'
  pod 'ReactiveObjC', '~> 3.0'
  pod 'ReactiveObjCBridge', '~> 1.1'
  pod 'AFNetworking', '~> 3.0'
  pod 'FXKeychain', '~> 1.5'
  pod 'Reachability', '~> 3.2'
  pod 'Fabric', '~> 1.6'
  pod 'Mantle', '~> 1.5.5'
  pod 'DeviceKit', '~> 1.0'
  pod 'TPKeyboardAvoiding', '~> 1.3'
  pod 'SwiftSimplify'
  pod 'PSPDFKit', podspec: 'https://customers.pspdfkit.com/cocoapods/8YzxfVzsGsqs4HKYsejmoeD6WEJ9ma/pspdfkit/7.5.0.podspec'

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
    pod 'Fabric', '~> 1.6'
    pod 'Crashlytics', '~> 3.8'
    pod 'Eureka', :git => 'https://github.com/xmartlabs/Eureka', :branch => 'Swift-3.3'
  end

  target 'Teacher' do
    project 'rn/Teacher/ios/Teacher.xcodeproj'

    pod 'Fabric', '~> 1.6'
    pod 'Crashlytics', '~> 3.8'
  end

  target 'TechDebt' do
    project 'Canvas/Canvas.xcodeproj'
    pod 'JSTokenField', '~> 1.1'
    pod 'Google/Analytics'
    pod 'FXKeychain', '~> 1.5'
    pod 'Crashlytics', '~> 3.8'
  end

  target 'Canvas' do
    project 'Canvas/Canvas.xcodeproj'
  end

  target 'CanvasCore' do
    project 'CanvasCore/CanvasCore.xcodeproj'
  end

  target 'CanvasKit1' do
    project 'Canvas/Canvas.xcodeproj'
  end

  target 'CanvasKit' do
    project 'Frameworks/CanvasKit/CanvasKit.xcodeproj'
  end

  target 'SoGrey' do
    project 'Frameworks/SoGrey/SoGrey.xcodeproj'
    pod 'EarlGrey', '~> 1.1'
    pod 'fishhook'
  end

  target 'CanvasKeymaster' do
    project 'Frameworks/CanvasKeymaster/CanvasKeymaster.xcodeproj'
  end

  abstract_target 'common_ui_tests' do
    target 'TeacherUITests' do
      pod 'EarlGrey', '~> 1.1'
      pod 'SwiftGRPC', git: 'https://github.com/grpc/grpc-swift.git'
      pod 'fishhook'
      project 'rn/Teacher/ios/Teacher.xcodeproj'
    end

    target 'StudentUITests' do
      pod 'EarlGrey', '~> 1.1'
      pod 'SwiftGRPC', git: 'https://github.com/grpc/grpc-swift.git'
      pod 'fishhook'
      project 'Canvas/Canvas.xcodeproj'
    end
  end

  target 'SoSeedySwift' do
    pod 'SwiftGRPC', git: 'https://github.com/grpc/grpc-swift.git'
    project 'Frameworks/SoSeedySwift/SoSeedySwift.xcodeproj'
  end
end

target 'GradesWidget' do
    use_frameworks!

    project 'Canvas/Canvas.xcodeproj'
    pod 'Mantle', '~> 1.5.5'
    pod 'AFNetworking', '~> 3.0'
    pod 'ReactiveObjC', '~> 3.0'
    pod 'FXKeychain', '~> 1.5'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
       config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
    end
    usesNonAppExAPI = %w[
      SVProgressHUD
      BugsnagReactNative
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

