# frozen_string_literal: true

require "decidim/proposals/admin"
require "decidim/proposals/api"
require "decidim/proposals/engine"
require "decidim/proposals/admin_engine"
require "decidim/proposals/import"
require "decidim/proposals/component"

module Decidim
  # This namespace holds the logic of the `Proposals` component. This component
  # allows users to create proposals in a participatory process.
  module Proposals
    autoload :ProposalSerializer, "decidim/proposals/proposal_serializer"
    autoload :CommentableProposal, "decidim/proposals/commentable_proposal"
    autoload :CommentableCollaborativeDraft, "decidim/proposals/commentable_collaborative_draft"
    autoload :MarkdownToProposals, "decidim/proposals/markdown_to_proposals"
    autoload :ParticipatoryTextSection, "decidim/proposals/participatory_text_section"
    autoload :DocToMarkdown, "decidim/proposals/doc_to_markdown"
    autoload :OdtToMarkdown, "decidim/proposals/odt_to_markdown"
    autoload :Valuatable, "decidim/proposals/valuatable"

    include ActiveSupport::Configurable

    # Public Setting that defines the similarity minimum value to consider two
    # proposals similar. Defaults to 0.25.
    config_accessor :similarity_threshold do
      0.25
    end

    # Public Setting that defines how many similar proposals will be shown.
    # Defaults to 10.
    config_accessor :similarity_limit do
      10
    end

    # Public Setting that defines how many proposals will be shown in the
    # participatory_space_highlighted_elements view hook
    config_accessor :participatory_space_highlighted_proposals_limit do
      4
    end

    # Public Setting that defines how many proposals will be shown in the
    # process_group_highlighted_elements view hook
    config_accessor :process_group_highlighted_proposals_limit do
      3
    end

    def self.create_default_states!(component, admin_user)
      default_states = {
        not_answered: { name: "not_answered", color: "#F5A623", default: true, include_in_stats: true },
        evaluating: { name: "evaluating", color: "#F5A623", default: false, include_in_stats: true },
        accepted: { name: "accepted", color: "#F5A623", default: false, include_in_stats: true },
        rejected: { name: "rejected", color: "#F5A623", default: false, include_in_stats: true },
        withdrawn: { name: "withdrawn", color: "#F5A623", default: false, include_in_stats: true }
      }

      default_states.each_key do |key|
        default_states[key][:object] = Decidim.traceability.create!(
          Decidim::Proposals::ProposalState,
          admin_user,
          title: { en: default_states[key][:name] },
          color: default_states[key][:color],
          default: default_states[key][:default],
          include_in_stats: default_states[key][:include_in_stats],
          component:
        )
      end
      default_states
    end
  end

  module ContentParsers
    autoload :ProposalParser, "decidim/content_parsers/proposal_parser"
  end

  module ContentRenderers
    autoload :ProposalRenderer, "decidim/content_renderers/proposal_renderer"
  end
end
