def join *args
  path = File.expand_path(File.join(*args))
  abort "Doesn't exist: #{path}" unless File.exist?(path)
  path
end

def delete path
  File.delete(path) if File.exist?(path)
end

protoc_bin = join(__dir__, 'protoc-3.5.0-osx-x86_64/bin/')
protoc = join(protoc_bin, 'protoc')
swift_plugin = join(protoc_bin, 'protoc-gen-swift')
swiftgrpc_plugin = join(protoc_bin, 'protoc-gen-swiftgrpc')

soseedy_dir = join(__dir__, '../../../android-uno/dataseedingapi/src/main/proto')

includes = [soseedy_dir]

# newline for the terminal. must not have space after \\
new_line = " \\\n"

soseedy_protos = Dir.glob(File.join(soseedy_dir, '**/*.proto')).map do |path|
  path = File.expand_path(path)
  path = path.gsub(soseedy_dir + '/', '')
  '"' + path + '"'
end

includes = includes.map {|path| "-I #{path}"}

swift_dst = join(__dir__, '../../rn/Teacher/ios/TeacherUITests')

command_args = [
    "--plugin=protoc-gen-swift=#{swift_plugin}",
    "--plugin=protoc-gen-swiftgrpc=#{swiftgrpc_plugin}",
    includes,
    soseedy_protos,
    %Q(--swift_out="#{swift_dst}"),
    %Q(--swiftgrpc_out="#{swift_dst}"),
].flatten.map {|e| "  #{e}"}.join(new_line)

command = [protoc, command_args].join(new_line).strip

puts command
`#{command}`

delete File.join(swift_dst, 'soseedy.server.pb.swift')
delete File.join(swift_dst, 'swiftgrpc.log')

# protoc <your proto files> \
# --swift_out=. \
# --swiftgrpc_out=.