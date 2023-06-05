# frozen_string_literal: true

# Copyright (c) 2016 Andy Pike - The MIT license
#
# This file has been copied from https://github.com/andypike/rectify/blob/master/lib/rectify/command.rb
# We have done this so we can decouple Decidim from any Virtus dependency, which is a dead project
# Please follow Decidim discussion to understand more https://github.com/decidim/decidim/discussions/7234
module Decidim
  class Command
    include ::Wisper::Publisher
    delegate :locale, to: :I18n

    def self.call(*args, **kwargs, &)
      event_recorder = Decidim::EventRecorder.new

      command = new(*args, **kwargs)
      command.subscribe(event_recorder)
      command.evaluate(&) if block_given?
      command.call

      event_recorder.events
    end

    def evaluate(&block)
      @caller = eval("self", block.binding, __FILE__, __LINE__)
      instance_eval(&block)
    end

    def transaction(&)
      ActiveRecord::Base.transaction(&) if block_given?
    end

    def method_missing(method_name, ...)
      if @caller.respond_to?(method_name, true)
        @caller.send(method_name, ...)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @caller.respond_to?(method_name, include_private)
    end

    def with_event_before
      ActiveSupport::Notifications.subscribe("#{event_namespace}:before", **event_arguments)
      yield
    end

    def with_event_after
      yield
      ActiveSupport::Notifications.subscribe("#{event_namespace}:after", **event_arguments)
    end

    def with_event_around
      ActiveSupport::Notifications.publish("#{event_namespace}:before", **event_arguments)
      yield
      ActiveSupport::Notifications.publish("#{event_namespace}:after", **event_arguments)
    end

    private

    def event_arguments
      raise "#{self.class} must implement #event_arguments"
    end

    def event_namespace
      @event_namespace ||= self.class.name.to_s.underscore.parameterize(separator: ".")
    end
  end
end
