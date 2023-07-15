# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class ProvidedFile < Base
        def add_training_data!(classifier, path, file)
          CSV.foreach("#{path}/#{file}", headers: true, force_quotes: false) do |row|
            next if row[1].blank?

            classifier.train row[0], row[1]
          end
        end
      end
    end
  end
end
