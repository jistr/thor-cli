require 'active_support/core_ext/hash/deep_merge'
require 'aeolus/cli/errors'

module Aeolus::Cli
  class Config < Hash
    DEFAULT_CONFIG_FILE = File.join(File.dirname(__FILE__),
                                    '..', '..', '..', # thor-cli gem dir
                                    'templates', 'default_config.yml')

    def initialize(config_hash)
      # save config hash
    end

    def push_config
      # set up ActiveResource::Base logger
      # set up Aeolus::Client::Base url, username, password
    end


    class << self
      def load_config(options)
        config_hash = {}
        config_hash.deep_merge!(config_file_hash(DEFAULT_CONFIG_FILE))
        config_hash.deep_merge!(config_file_hash(config_file_to_load)) if config_file_to_load
        config_hash.deep_merge!(options_hash(options))
        self.new(config_hash)
      end

      private

      def config_file_to_load
        env_config = ENV['AEOLUS_CLI_CONF']
        home_config = "#{ENV['HOME']}/.aeolus-cli"
        global_config = "/etc/aeolus-cli"

        return env_config    if env_config
        return home_config   if File.exists?(home_config)
        return global_config if File.exists?(global_config)
        nil
      end

      def config_file_hash(file_name)
        unless File.file?(file_name)
          raise Aeolus::Cli::ConfigError.new("Config file '#{file_name}' does not exist.")
        end

        YAML::load(File.read(file_name))
      end

      def options_hash(options)
        hash = {}
      end
    end
  end

end
