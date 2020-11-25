# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a initiative committee member.
    class InitiativeCommitteeMemberType < Decidim::Api::Types::BaseObject
      graphql_name "InitiativeCommitteeMemberType"
      description "A initiative committee member"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, "Internal ID for this member of the committee", null: false
      field :user, Decidim::Core::UserInterface, "The decidim user for this initiative committee member", null: true

      field :state, Int, "Type of the committee member", null: true
    end
  end
end
