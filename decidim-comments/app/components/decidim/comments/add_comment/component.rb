# frozen_string_literal: true

module Decidim
  module Comments
    module AddComment
      class Component < Decidim::BaseComponent
        attr_reader :commentable, :options
        def initialize(commentable, options = {})
          @commentable = commentable
          @options = options
        end
      end
    end
  end
end
