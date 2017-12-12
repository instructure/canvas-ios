require 'fileutils'

teacher_ui = File.join(__dir__, '../rn/Teacher/ios/TeacherUITests/**/*.lproj')
Dir.glob(teacher_ui) { |lproj| FileUtils.rm_rf lproj }

# todo: automate removing PBXVariantGroup name = InfoPlist.strings; & children from Teacher.xcodeproj/project.pbxproj
# https://github.com/instructure/ios/pull/1315/files
