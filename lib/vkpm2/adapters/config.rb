# frozen_string_literal: true

module VKPM2
  module Adapters
    class Config
      ABSOLUTE_DIR = File.join(Dir.home, '.config', 'vkpm').freeze
      FILE = 'config.yaml'

      def initialize(client: Clients::Config.new)
        @client = client

        client.append_path(ABSOLUTE_DIR)
        client.filename = FILE

        client.write unless client.exist?
      end

      # @param [String] key
      def set(key, value)
        raise VKPM2::Error, "Invalid key: #{key}" unless ACCEPTABLE_KEYS.include?(key)

        client.set(key, value:)
      end

      def write
        client.write(force: true)
      end

      private

      attr_reader :client

      ACCEPTABLE_KEYS = %w[backend.domain].freeze
    end
  end
end
