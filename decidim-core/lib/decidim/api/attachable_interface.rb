# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a attachable object.
    module AttachableInterface
      include Types::BaseInterface
      description "An interface that can be used in objects with attachments"

      field :attachments, [Decidim::Core::AttachmentType, null: true], "This object's attachments", null: false
    end
  end
end
