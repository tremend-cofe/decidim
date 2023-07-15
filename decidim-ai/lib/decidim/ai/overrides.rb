# frozen_string_literal: true

module Decidim
  module Ai
    module Overrides
      autoload :CreateDebate, "decidim/tools/ai/overrides/create_debate"
      autoload :UpdateDebate, "decidim/tools/ai/overrides/update_debate"
      autoload :CreateMeeting, "decidim/tools/ai/overrides/create_meeting"
      autoload :UpdateMeeting, "decidim/tools/ai/overrides/update_meeting"
      autoload :CreateComment, "decidim/tools/ai/overrides/create_comment"
      autoload :UpdateComment, "decidim/tools/ai/overrides/update_comment"
      autoload :CreateCollaborativeDraft, "decidim/tools/ai/overrides/create_collaborative_draft"
      autoload :UpdateCollaborativeDraft, "decidim/tools/ai/overrides/update_collaborative_draft"
      autoload :CreateProposal, "decidim/tools/ai/overrides/create_proposal"
      autoload :UpdateProposal, "decidim/tools/ai/overrides/update_proposal"
      autoload :BlockUser, "decidim/tools/ai/overrides/block_user"
      autoload :HideResource, "decidim/tools/ai/overrides/hide_resource"
    end
  end
end
