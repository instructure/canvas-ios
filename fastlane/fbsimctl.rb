# Copyright (C) 2016 - present Instructure, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

fastlane_require 'posix-spawn'
require 'fileutils'
require 'json'
require 'uri'
fastlane_require 'httpclient'

class FBSimctl
  attr_reader :video_out

  def initialize opts={}
    @video_out = opts.fetch(:video_out)
    FileUtils.rm_rf @video_out

    @udid = ::TEST_SIMULATOR.udid
    @port = 8091

    @client = HTTPClient.new
    @client.transparent_gzip_decompression = true
  end

  def fbsimctl
    @fbsimctl ||= '/usr/local/opt/fbsimctl/bin/fbsimctl'
  end

  def boot_simulator
    return if @boot_simulator

    @boot_simulator ||= begin
      arguments = [
          '--json',
          @udid,
          'boot'
      ].join(' ')
      "#{fbsimctl} #{arguments}"
    end

    puts @boot_simulator
    child = POSIX::Spawn::Child.new(@boot_simulator)

    output = "#{child.out}\n#{child.err}"

    # Ignore already booted simulator.
    return if output.include? "to be Shutdown, but it was 'Booted'"

    abort("Simulator boot failed! #{output}") unless child.status.success?
  end

  def start_server
    return if @start_server

    boot_simulator

    # Remove any existing fbsimctl process
    `killall -KILL fbsimctl > /dev/null 2&>1`

    @start_server ||= begin
      arguments = [
          'listen',
          "--http #{@port}"
      ].join(' ')
      "#{fbsimctl} #{arguments}"
    end

    puts @start_server
    @pid, @in, @out, @err = POSIX::Spawn::popen4(@start_server)
    sleep 2 # wait for http server to startup.
  end

  def stop_server
    Process.kill(:SIGTERM, @pid)

    [@in, @out, @err].each { |io| io.close unless io.nil? || io.closed? }
    Process.wait(@pid) if @pid
  end

  def _get_url endpoint
    "http://localhost:#{@port}/#{@udid}/#{endpoint}"
  end

  def _record_request start_value
    url = _get_url 'record'

    args = {
        header: {
            'content-type': 'application/json',
        },
        body: %Q({ "start": #{start_value} })
    }

    @client.post(url, args)
  end

  def start_recording
    # post to: localhost:8090/A34700F6-F9E1-4AF4-9748-4C6A12A03C19/record
    # with: { "start": true }
    response = _record_request(true)

    unless response.status_code == 200
      abort("Start recording failed:\n#{response.body}")
    end

    @video_path = "#{Dir.home}/Library/Developer/CoreSimulator/Devices/#{@udid}/data/fbsimulatorcontrol/diagnostics/video.mp4"
  end

  def stop_recording
    # post to: localhost:8090/A34700F6-F9E1-4AF4-9748-4C6A12A03C19/record
    # with: { "start": false }

    _record_request(false)

    abort("No video at path #{@video_path}") unless File.exist?(@video_path || '')
    FileUtils.cp @video_path, @video_out
  end
end
