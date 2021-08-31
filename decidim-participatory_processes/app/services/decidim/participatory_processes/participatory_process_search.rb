# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # Service that encapsulates all logic related to filtering participatory processes.
    class ParticipatoryProcessSearch < ParticipatorySpaceSearch
      def initialize(options = {})
        base_relation = options.has_key?(:base_relation) ? options.delete(:base_relation) : ParticipatoryProcess.all
        super(base_relation, options)
      end

      def search_date
        case date
        when "active"
          query.active.order(start_date: :desc)
        when "past"
          query.past.order(end_date: :desc)
        when "upcoming"
          query.upcoming.order(start_date: :asc)
        else # Assume 'all'
          timezone = ActiveSupport::TimeZone.find_tzinfo(Time.zone.name).identifier
          tzdate = Arel::Nodes::InfixOperation.new("at time zone", Arel.sql("CURRENT_DATE"), Arel::Nodes::Quoted.new(timezone))
          date = Arel::Nodes::NamedFunction.new("CAST", [tzdate.as(Arel.sql("DATE"))])
          subtraction = Arel::Nodes::Subtraction.new(Arel.sql("start_date"), date)
          abs = Arel::Nodes::NamedFunction.new("ABS", [subtraction])
          query.order(abs)
        end
      end
    end
  end
end
