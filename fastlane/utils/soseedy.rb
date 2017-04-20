# Copyright (C) 2017 - present Instructure, Inc.
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

fastlane_require 'git'
fastlane_require 'retriable'

class SoSeedy
  @first_run = true

  class << self
    def seed(args = {})
      app           = args.fetch(:app)
      script        = seed_script(app)
      single_class  = args[:class]
      single_method = args[:method]

      script << " -c #{single_class}" if single_class
      script << " -m #{single_method}" if single_method

      execute_script(script)
    end

    def robo(args = {})
      app    = args.fetch(:app)
      script = robo_script(app)
      execute_script(script)
    end

    private

    def execute_script(script)
      if @first_run
        @first_run = false

        cloned = File.directory?(repo)
        if cloned
          @git = Git.open(repo)

          if on_master? && nothing_to_commit?
            execute_action('Pull latest SoSeedy changes') { @git.pull }
          else
            # TODO: check if automatic rebase is possible
            warning = 'Attention!!!'
            warning += ' SoSeedy is not on master branch.' unless on_master?
            warning += ' SoSeedy has uncommitted changes.' unless nothing_to_commit?
            FastlaneCore::UI.header(warning.yellow)
          end
        else
          execute_action('Cloning SoSeedy') do
            with_retry { @git = Git.clone(git_url, repo) }
          end
        end

        # always run bundle install once for people
        # otherwise we're missing all the gem dependencies
        execute_action('Install SoSeedy dependencies') do
          _execute(dir: soseedy_dir, command: install)
        end
      end

      execute_action("Seeding data from SoSeedy branch: #{@git.current_branch}") do
        android_uno_root = join(__dir__, '../..')
        _execute(dir: android_uno_root, command: join(soseedy_dir, script))
      end
    end

    def nothing_to_commit?
      %i[changed added deleted untracked].all? { |method| @git.status.send(method).empty? }
    end

    def on_master?
      @git.current_branch == 'master'
    end

    def repo
      join('..', '..', 'mobile_qa')
    end

    def soseedy_dir
      File.join(repo, 'SoSeedy')
    end

    def git_url
      'git@github.com:instructure/mobile_qa.git'
    end

    def install
      'bundle install'
    end

    def seed_script(app)
      "bin/soseedy -a #{app}"
    end

    def robo_script(app)
      "bin/soseedy robo -a #{app}"
    end

    # Wrapper method for executing network requests with retires on failure.
    # @param [Block] block of code to be wrapped with retry
    # @example
    #   with_retry { @git = Git.clone(git_url, repo) }
    # @return [void]
    def with_retry
      Retriable.retriable(tries: 5, base_interval: 1.0, multiplier: 1.0, rand_factor: 0.0) do
        yield
      end
    end
  end
end
