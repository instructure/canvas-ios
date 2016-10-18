source 'git@github.com:instructure/ios-podspecs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'AllTheThings.xcworkspace'

target 'Canvas' do
    project 'Canvas/Canvas.xcodeproj'

    use_frameworks!
    inhibit_all_warnings!

    pod 'JSTokenField', '~> 1.1'
end

target 'TechDebt' do
    project 'Canvas/Canvas.xcodeproj'

    use_frameworks!
    inhibit_all_warnings!
    pod 'JSTokenField', '~> 1.1'
    pod 'Google/Analytics'
end

target 'SpeedGrader' do
    project 'SpeedGrader/SpeedGrader.xcodeproj'

    use_frameworks!
    inhibit_all_warnings!

    pod 'Google/Analytics'

    pod 'SimulatorStatusMagic', :configurations => ['Debug']
end


