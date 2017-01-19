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

# https://github.com/fastlane/fastlane/blob/7908e2af585ce859312972bc2bd9e361f4229b86/fastlane/lib/fastlane/fast_file.rb
def fastlane_require(gem_name)
  Fastlane::FastlaneRequire.install_gem_if_needed(gem_name: gem_name, require_gem: true)
end

def retry_cmd cmd_name, limit = 3, &block
  # if execution fails then we retry up to limit - 1 times.
  tries = limit
  begin
    block.call
  rescue
    unless (tries -= 1).zero?
      puts "Retry ##{limit - tries}: #{cmd_name}"
      retry
    end
    raise
  end
end

def ui_error msg
  FastlaneCore::UI.error "ERROR: #{msg}"
  abort
end

def ui_important msg
  FastlaneCore::UI.important msg
end

def get_simulator opts={}
  ios_version = opts.fetch(:ios_version)
  name = opts.fetch(:name)

  all_devices = FastlaneCore::Simulator.all
  device = all_devices.detect do |device|
    # ios version is the same as os version.
    device.is_simulator == true &&
        device.ios_version == ios_version &&
        device.name == name &&
        device.os_type == 'iOS'
  end

  unless device
    ui_important "Available devices: #{all_devices.map { |d| d.name + ' ' + d.ios_version }}"
    ui_error "No device found for #{name} #{ios_version}"
  end

  device
end

TEST_SIMULATOR = get_simulator(name: 'iPhone 7 Plus', ios_version: '10.2')
