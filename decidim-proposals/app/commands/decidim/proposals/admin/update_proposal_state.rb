# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class UpdateProposalState < Decidim::Command
        include TranslatableAttributes

        def initialize(form, state)
          @form = form
          @state = state
        end

        def call
          return broadcast(:invalid) if form.invalid?

          update_state
          broadcast(:ok, state)
        end

        private

        attr_reader :form, :state

        def update_state
          Decidim.traceability.update!(
            state,
            form.current_user,
            **attributes
          )
        end

        def attributes
          {
            title: form.title,
            description: form.description,
            color: form.color,
            default: form.default,
            include_in_stats: form.include_in_stats
          }
        end
      end
    end
  end
end
