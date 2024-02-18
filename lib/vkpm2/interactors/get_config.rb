# frozen_string_literal: true

module VKPM2
  module Interactors
    class GetConfig
      include Interactor

      def call
        context.config = Adapters::Config.new
      end
    end
  end
end
