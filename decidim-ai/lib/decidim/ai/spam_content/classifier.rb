# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class Classifier
        def initialize(organization)
          @organization = organization
          @available_locales = organization.available_locales
          @classifier = Repository.new
          @score = 0.0
          @reasons = {
            classifier: false,
            language: false,
            links: false,
            forbidden_words: false
          }
          @messages = []
        end

        def score
          @reasons.filter_map { |i| i.last ? 1 : 0 }.reduce(:+).to_f / 4
        end

        def classify!(text, locale)
          compute_classification_score text
          compute_forbidden_words text
          compute_language_scope text, locale
          compute_links_scope text
        end

        def details
          @messages.join("<br>")
        end

        private

        # this fetches and compute the class of the text (either spam or not spam)
        def compute_classification_score(text)
          return unless @classifier.classify(text) == "Spam"

          Rails.logger.info "The Classification engine marked #{text} this as spam: #{@classifier.classifications(text).inspect}"

          @reasons[:classifier] = true
          @messages << "The Classification engine marked this as spam: #{@classifier.classify_with_score(text).inspect}"
        end

        # determines if the posted content is in the supported languages
        def compute_language_scope(text, _locale)
          return if text.empty?

          detected_language = CLD.detect_language(text)
          return if @available_locales.include?(detected_language[:code])

          @reasons[:language] = true
          @messages << "The content has been detected as #{detected_language.inspect}."
        end

        # this analyzes text vs links score
        def compute_links_scope(text); end

        # this computes a score based on how many words are restricted
        def compute_forbidden_words(text)
          list = forbidden_keyword_list.map { |word| ClassifierReborn::Hasher.word_hash(word, true) }.reduce({}, :merge)
          word_list = ClassifierReborn::Hasher.word_hash(text, true).keys & list.keys

          return unless word_list.any?

          @reasons[:forbidden_words] = true
          @messages << "The content matched the forbidden keywords list for #{word_list.join(",")}"
        end

        def forbidden_keyword_list
          Decidim::Ai::ForbiddenKeyword.where(organization: @organization).pluck(:word)
        end
      end
    end
  end
end
