# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Resource
        autoload :Base, "decidim/tools/ai/resources/base"
        autoload :Comment, "decidim/tools/ai/resources/comment"
        autoload :Meeting, "decidim/tools/ai/resources/meeting"
        autoload :Proposal, "decidim/tools/ai/resources/proposal"
        autoload :CollaborativeDraft, "decidim/tools/ai/resources/collaborative_draft"
        autoload :Debate, "decidim/tools/ai/resources/debate"
        autoload :UserBaseEntity, "decidim/tools/ai/resources/user_base_entity"
        autoload :ProvidedFile, "decidim/tools/ai/resources/provided_file"
        autoload :Wrapper, "decidim/tools/ai/resources/wrapper"
      end
    end
  end
end
