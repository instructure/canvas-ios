def join *args
  path = File.expand_path(File.join(*args))
  abort "Doesn't exist: #{path}" unless File.exist?(path)
  path
end

def delete path
  File.delete(path) if File.exist?(path)
end

protoc = join(__dir__, 'protoc-3.5.0-osx-x86_64/bin/protoc')

soseedy_proto = 'soseedy.proto'
soseedy_dir = join(__dir__, '../../../android-uno/dataseedingapi/src/main/proto')

swift_dst = join(__dir__, '../../rn/Teacher/ios/TeacherUITests')

command = %Q(protoc -I "#{soseedy_dir}" "#{soseedy_proto}" --swift_out="#{swift_dst}" --swiftgrpc_out="#{swift_dst}")
puts command

`#{command}`

delete File.join(swift_dst, 'soseedy.server.pb.swift')
delete File.join(swift_dst, 'swiftgrpc.log')

# protoc <your proto files> \
# --swift_out=. \
# --swiftgrpc_out=.