

source 'git@github.com:instructure/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AllTheThings.xcworkspace'
inhibit_all_warnings!
platform :ios, '10.0'

abstract_target 'defaults' do
  use_frameworks!

  pod 'ReactiveCocoa', '~> 5.0'
  pod 'Marshal', '~> 1.1'
  pod 'Result', '~> 3.2'
  pod 'Cartography', '~> 1.1'
  pod 'ReactiveSwift'
  pod 'CWStatusBarNotification', git: 'https://github.com/derrh/CWStatusBarNotification.git', branch: 'framework'
  pod 'Kingfisher', '~> 3.2'
  pod 'JSTokenField', '~> 1.1'
  pod 'CocoaLumberjack', '~> 2.4.0'
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
  pod 'Eureka', git: 'https://github.com/xmartlabs/Eureka', branch: 'feature/Xcode9-Swift3_2'

  target 'Parent' do
    project 'Parent/Parent.xcodeproj'
    pod 'Fabric', '~> 1.6'
    pod 'Crashlytics', '~> 3.8'
  end

  target 'EverythingBagel' do
    project 'Frameworks/EverythingBagel/EverythingBagel.xcodeproj'
    pod 'Fabric', '~> 1.6'
    pod 'Crashlytics', '~> 3.8'
  end
  
  target 'Teacher' do
      project 'rn/Teacher/ios/Teacher.xcodeproj'
	  pod 'PocketSVG', '~> 2.2'
	  pod 'SDWebImage', '~> 4.1'
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

  target 'CanvasKit1' do
    project 'Canvas/Canvas.xcodeproj'
  end

  target 'CanvasKit' do
    project 'Frameworks/CanvasKit/CanvasKit.xcodeproj'
  end

  target 'SoAnnotated' do
    project 'Frameworks/SoAnnotated/SoAnnotated.xcodeproj'
  end

  target 'SoLazy' do
    project 'Frameworks/SoLazy/SoLazy.xcodeproj'
  end

  target 'MyLittleViewController' do
    project 'Canvas/MLVC/MyLittleViewController.xcodeproj'
  end

  target 'Pretty' do
    project 'Frameworks/SoPretty/SoPretty.xcodeproj'
  end

  target 'SoPretty' do
    project 'Frameworks/SoPretty/SoPretty.xcodeproj'
  end

  target 'TooLegit' do
    project 'Frameworks/TooLegit/TooLegit.xcodeproj'
  end

  target 'NotificationKit' do
    project 'Frameworks/NotificationKit/NotificationKit.xcodeproj'
  end

  target 'SoProgressive' do
    project 'Frameworks/SoProgressive/SoProgressive.xcodeproj'
  end

  target 'AttendanceLE' do
    project 'Frameworks/Attendance/Attendance.xcodeproj'
  end

  target 'SoPersistent' do
    project 'Frameworks/SoPersistent/SoPersistent.xcodeproj'
  end
  
  target 'PersistentCrashing' do
    project 'Frameworks/SoPersistent/SoPersistent.xcodeproj'
  end

  target 'CanvasKeymaster' do
    project 'Frameworks/CanvasKeymaster/CanvasKeymaster.xcodeproj'
  end

  target 'EnrollmentKit' do
    project 'Frameworks/Enrollments/Enrollments.xcodeproj'
  end

  target 'Enrollments' do
    project 'Frameworks/Enrollments/Enrollments.xcodeproj'
  end

  target 'Todo' do
    project 'Frameworks/Todo/Todo.xcodeproj'
  end

  target 'TodoKit' do
    project 'Frameworks/Todo/Todo.xcodeproj'
  end

  target 'Pages' do
    project 'Frameworks/Pages/Pages.xcodeproj'
  end

  target 'PageKit' do
    project 'Frameworks/Pages/Pages.xcodeproj'
  end

  target 'MediaKit' do
    project 'Frameworks/MediaKit/MediaKit.xcodeproj'
  end

  target 'Peeps' do
    project 'Frameworks/Peeps/Peeps.xcodeproj'
  end

  target 'SuchActivity' do
    project 'Frameworks/SuchActivity/SuchActivity.xcodeproj'
  end

  target 'Files' do
    project 'Frameworks/FileKit/FileKit.xcodeproj'
  end

  target 'FileKit' do
    project 'Frameworks/FileKit/FileKit.xcodeproj'
  end

  target 'QuizKit' do
    project 'Frameworks/Quizzes/Quizzes.xcodeproj'
  end

  target 'Assignments' do
    project 'Frameworks/Assignments/Assignments.xcodeproj'
  end

  target 'AssignmentKit' do
    project 'Frameworks/Assignments/Assignments.xcodeproj'
  end

  target 'SoEdventurous' do
    project 'Frameworks/SoEdventurous/SoEdventurous.xcodeproj'
  end

  target 'SoAnnotated_PreSubmission' do
    project 'Frameworks/SoAnnotated-PreSubmission/SoAnnotated-PreSubmission.xcodeproj'
  end

  target 'Calendar' do
    project 'Frameworks/Calendar/Calendar.xcodeproj'
  end

  target 'CalendarKit' do
    project 'Frameworks/Calendar/Calendar.xcodeproj'
  end

  target 'SoSupportive' do
    project 'Frameworks/SoSupportive/SoSupportive.xcodeproj'
  end

  target 'Keymaster' do
    project 'Frameworks/Keytester/Keytester.xcodeproj'

  end

  target 'Discussions' do
    project 'Frameworks/Discussions/Discussions.xcodeproj'
  end

  target 'DiscussionKit' do
    project 'Frameworks/Discussions/Discussions.xcodeproj'
  end

  target 'Airwolf' do
    project 'Parent/Airwolf/Airwolf.xcodeproj'
  end

  target 'ObserverAlertKit' do
    project 'Parent/ObserverAlertKit/ObserverAlertKit.xcodeproj'
  end

  abstract_target 'common_tests' do
    pod 'Nimble', '~> 7.0'
    pod 'Quick', '~> 1.1'
    pod 'DVR', '~> 1.0'

    target 'SoAutomated' do
      project 'Frameworks/SoAutomated/SoAutomated.xcodeproj'
    end
    target 'SoAutomatedTests' do
      project 'Frameworks/SoAutomated/SoAutomated.xcodeproj'
    end
    target 'SoPrettyTests' do
      project 'Frameworks/SoPretty/SoPretty.xcodeproj'
    end
    target 'TooLegitTests' do
      project 'Frameworks/TooLegit/TooLegit.xcodeproj'
    end
    target 'SoPersistentTests' do
      project 'Frameworks/SoPersistent/SoPersistent.xcodeproj'
    end
    target 'PersistentCrashingTests' do
      project 'Frameworks/SoPersistent/SoPersistent.xcodeproj'
    end
    target 'EnrollmentKitTests' do
      project 'Frameworks/Enrollments/Enrollments.xcodeproj'
    end
    target 'TodoKitTests' do
      project 'Frameworks/Todo/Todo.xcodeproj'
    end
    target 'FileKitTests' do
      project 'Frameworks/FileKit/FileKit.xcodeproj'
    end
    target 'PageKitTests' do
      project 'Frameworks/Pages/Pages.xcodeproj'
    end
    target 'CanvasTests' do
      project 'Canvas/Canvas.xcodeproj'
    end
    target 'CalendarKitTests' do
      project 'Frameworks/Calendar/Calendar.xcodeproj'
    end
    target 'AssignmentKitTests' do
      project 'Frameworks/Assignments/Assignments.xcodeproj'
    end
    target 'SoEdventurousTests' do
      project 'Frameworks/SoEdventurous/SoEdventurous.xcodeproj'
    end
    target 'DiscussionKitTests' do
      project 'Frameworks/Discussions/Discussions.xcodeproj'
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    # puts "=== #{target.name}"
    next unless target.name == 'CWStatusBarNotification' || target.name == 'SVProgressHUD'
    puts "*** Setting #{target.name} target to APPLICATION_EXTENSION_API_ONLY = NO ***"
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
    end
  end
end
