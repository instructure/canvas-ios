def require_install gem_name
  begin
    require gem_name
  rescue LoadError
    rubygem_name = gem_name.gsub('/', '-')

    system("gem install #{rubygem_name} --no-document")
    Gem.clear_paths
    require gem_name
  end
end

require_install 'posix/spawn'
require 'fileutils'
require 'json'

class FBSimctl
  attr_reader :video_out

  def initialize opts={}
    @video_out = opts.fetch(:video_out)
    FileUtils.rm_rf @video_out
  end

  # assumes a booted simulator.
  # fbsimctl --json A34700F6-F9E1-4AF4-9748-4C6A12A03C19 boot
  def fbsimctl_record_command
    # do **not** redirect stderr to stdout. that will mess up json output.
    @fbsimctl_record_command ||= begin
      fbsimctl = File.expand_path(File.join(__dir__, 'fbsimctl', 'bin', 'fbsimctl'))
      arguments = [
          '--json',
          'record start --',
          'listen --',
          'record stop'
      ].join(' ')
      "#{fbsimctl} #{arguments}"
    end
  end

  def _process_wait &block
    # todo: timeout instead of looping forever.
    while true do
      line = @out.readline rescue break
      json = JSON.parse(line) rescue {}

      if block.call(json)
        break
      end
    end
  end

  # {"event_type":"started","timestamp":1478809645,"subject":{"type":"empty"},"event_name":"listen"}
  # {"event_type":"ended","timestamp":1478809645,"subject":{"type":"empty"},"event_name":"listen"}
  def process_wait_for_event event_name, event_type
    puts "Waiting for #{event_name} #{event_type}"
    _process_wait { |json| json['event_name'] == event_name && json['event_type'] == event_type }
  end

  # {"event_type":"discrete","timestamp":1478811432,"level":"info",
  # "subject":"Started Recording video at path \/Users\/user\/Library\/Developer\/CoreSimulator\/Devices\/A34700F6-F9E1-4AF4-9748-4C6A12A03C19\/data\/fbsimulatorcontrol\/diagnostics\/video.mp4",
  # "event_name":"log"}
  def process_wait_for_video_path
    puts 'Waiting for video path'
    event = ''
    _process_wait { |json| event = json['subject']; event.include?('Started Recording video at path') }

    video_path = event.match(/Started Recording video at path (.*)/)
    video_path[1] if video_path && video_path.length == 2
  end

  def process_terminate
    Process.kill(:SIGTERM, @pid)
  end

  def start_recording
    puts fbsimctl_record_command
    @pid, @in, @out, @err = POSIX::Spawn::popen4(fbsimctl_record_command)

    process_wait_for_event('listen', 'started')
    @video_path = process_wait_for_video_path

    puts "parsed video: #{@video_path}"
  end

  def stop_recording
    # must sleep a few seconds before termination to avoid 0 byte video.
    sleep 2
    process_terminate

    process_wait_for_event('listen', 'ended')
    process_wait_for_event('shutdown', 'ended')
    Process.waitpid(@pid)

    abort("No video at path #{@video_path}") unless File.exist?(@video_path || '')
    FileUtils.cp @video_path, @video_out
  end
end
