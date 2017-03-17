
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

fastlane_require 'posix-spawn'

def _execute args={}
  args = {command: args} if args.is_a?(String)
  args[:command] = "set -o pipefail && #{args[:command]}" if args[:command].include? '|'

  args[:print_all] = args.fetch(:print_all, true)
  args[:print_command] = args.fetch(:print_command, true)

  # 'fastlane' is the default cwd. change to parent dir.
  dir = args.fetch(:dir, repo_root_dir)
  args.delete(:dir)
  Dir.chdir(dir) do
    FastlaneCore::CommandExecutor.execute args
  end
end

# Invoke execute_action to show up in the Fastlane step report.
def execute_action name, &block
  ::Fastlane::Actions.execute_action(name, &block)
end