# frozen_string_literal: true

module Decidim
  module Initiatives
    # This type represents a Initiative.
    class InitiativeType < Types::BaseObject

      implements Decidim::Core::ParticipatorySpaceInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::AuthorInterface
      implements Decidim::Initiatives::InitiativeTypeInterface
      description "A initiative"
      graphql_name "Initiative"

      field :description, Decidim::Core::TranslatedFieldType, "The description of this initiative.", null: true
      field :slug, String, null: false
      field :hashtag, String, "The hashtag for this initiative", null: true
      field :created_at, Decidim::Core::DateTimeType, "The time this initiative was created", null: false
      field :updated_at, Decidim::Core::DateTimeType, "The time this initiative was updated", null: false
      field :published_at, Decidim::Core::DateTimeType, "The time this initiative was published", null: false
      field :reference, String, "Reference prefix for this initiative", null: false
      field :state, String, "Current status of the initiative", null: true
      field :signature_type, String, "Signature type of the initiative", null: true
      field :signature_start_date, Decidim::Core::DateType, "The signature start date", null: false
      field :signature_end_date, Decidim::Core::DateType, "The signature end date", null: false
      field :offline_votes, Integer, "The number of offline votes in this initiative", null: true
      field :initiative_votes_count, Integer, "The number of votes in this initiative", null: true
      field :initiative_supports_count, Integer, "The number of supports in this initiative", null: true
      field :author, Decidim::Core::AuthorInterface, "The initiative author", null: false

      def author
        object.user_group || object.author
      end

      field :committee_members, [Decidim::Initiatives::InitiativeCommitteeMemberType, null: true], null: true
    end
  end
end
