# frozen_string_literal: true

require "decidim/api/component_interface"
require "decidim/api/participatory_space_interface"

module Decidim
  # This module's job is to extend the API with custom fields related to
  # decidim-core.
  module QueryExtensions
    # Public: Extends a type with `decidim-core`'s fields.
    #
    # type - A GraphQL::BaseType to extend.
    #
    # Returns nothing.
    def self.included(base)
        Decidim.participatory_space_manifests.each do |participatory_space_manifest|
          base.field participatory_space_manifest.name.to_s.camelize(:lower), type: [participatory_space_manifest.query_type.constantize],
                description: "Lists all #{participatory_space_manifest.name}", null: true do
            def resolve_field(object:, args:, context:)
              participatory_space_manifest.query_list.constantize.new(manifest: participatory_space_manifest).call(object, args, context)
            end
          end
          base.field participatory_space_manifest.name.to_s.singularize.camelize(:lower), type: participatory_space_manifest.query_type.constantize,
                description: "Finds a #{participatory_space_manifest.name.to_s.singularize}", null: true do
            def resolve_field(object:, args:, context:)
              participatory_space_manifest.query_finder.constantize.new(manifest: participatory_space_manifest).call(object, args, context)
            end
          end
        end

        base.field :component, Decidim::Core::ComponentInterface, description: "Lists the components this space contains.", null: true do
          argument :id, GraphQL::Types::ID, "The ID of the component to be found", required: true

          def resolve_field(object, args, ctx)
            component = Decidim::Component.published.find_by(id: args[:id])
            component&.organization == ctx[:current_organization] ? component : nil
          end
        end

        base.field :session, Core::SessionType, description: "Return's information about the logged in user", null: true do
          def resolve_field(object, args, ctx)
            ctx[:current_user]
          end
        end

        base.field :decidim, Core::DecidimType, "Decidim's framework properties.", null: true

        def decidim
          Decidim
        end

        base.field :organization, Core::OrganizationType, "The current organization", null: true

        def organization
          context[:current_organization]
        end

        base.field :hashtags, [Core::HashtagType, null: true], description: "The hashtags for current organization", null: true do
          argument :name, GraphQL::Types::String, "The name of the hashtag", required: false

          def resolve_field(object, args, ctx)
            Decidim::HashtagsResolver.new(ctx[:current_organization], args[:name]).hashtags
          end
        end

        base.field :metrics, [Decidim::Core::MetricType, null: true], null: true do
          argument :names, [GraphQL::Types::String, null: true], "The names of the metrics you want to retrieve", required: false
          argument :space_type, GraphQL::Types::String, "The type of ParticipatorySpace you want to filter with", required: false
          argument :space_id, GraphQL::Types::Int, "The ID of ParticipatorySpace you want to filter with", required: false

          def resolve_field(object, args, ctx)
            manifests = if args[:names].blank?
                          Decidim.metrics_registry.all
                        else
                          Decidim.metrics_registry.all.select do |manifest|
                            args[:names].include?(manifest.metric_name.to_s)
                          end
                        end
            filters = {}
            if args[:space_type].present? && args[:space_id].present?
              filters[:participatory_space_type] = args[:space_type]
              filters[:participatory_space_id] = args[:space_id]
            end

            manifests.map do |manifest|
              Decidim::Core::MetricResolver.new(manifest.metric_name, ctx[:current_organization], filters)
            end
          end
        end

        base.field :user, type: Core::AuthorInterface, description: "A participant (user or group) in the current organization", null: true do
          def resolve_field(_obj:, args:, ctx:)
            Core::UserEntityFinder.new.call(_obj, args, ctx)
          end
        end
        base.field :users, type: [Core::AuthorInterface], description: "The participants (users or groups) for the current organization", null: true do
          def resolve_field(_obj:, args:, ctx:)
            Core::UserEntityList.new.call(_obj, args, ctx)
          end
        end

    end
  end
end
