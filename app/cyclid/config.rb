# frozen_string_literal: true
# Copyright 2016 Liqwyd Ltd.
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

require 'yaml'

module Cyclid
  module API
    # Cyclid API configuration
    class Config
      attr_reader :database, :log, :dispatcher, :builder, :plugins

      def initialize(path)
        config = YAML.load_file(path)
        server = config['server']

        @database = server['database']
        @log = server['log'] || File.join(%w(/ var log cyclid server))
        @dispatcher = server['dispatcher']
        @builder = server['builder']
        @plugins = server['plugins'] || {}
      rescue StandardError => ex
        abort "Failed to load configuration file #{path}: #{ex}"
      end
    end
  end
end
