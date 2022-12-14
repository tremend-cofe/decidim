# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Resource
        class Wrapper
          def initialize(klass)
            @wrapped = "Decidim::Tools::Ai::Resource::#{klass.name.demodulize}".safe_constantize.new
          end

          def train(classifier)
            @wrapped.add_training_data!(classifier)
          end

          delegate :fields, to: :wrapped

          attr_reader :wrapped
        end
      end
    end
  end
end
