# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      autoload :Repository, "decidim/tools/ai/spam_content/repository"
      autoload :InvalidBackendError, "decidim/tools/ai/spam_content/invalid_backend_error"
      autoload :Classifier, "decidim/tools/ai/spam_content/classifier"
    end
  end
end
