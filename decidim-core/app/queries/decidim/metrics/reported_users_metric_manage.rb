# frozen_string_literal: true

module Decidim
  module Metrics
    # Metric manager for User's registries
    class ReportedUsersMetricManage < Decidim::MetricManage
      def metric_name
        "reported_users"
      end

      private

      def query
        return @query if @query

        @query = Decidim::User.where(organization: @organization).joins(:user_moderation)
        @query
      end

      def quantity
        @quantity ||= @query.count
      end
    end
  end
end
