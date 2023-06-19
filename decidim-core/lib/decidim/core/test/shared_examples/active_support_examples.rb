# frozen_string_literal: true

shared_examples "fires an ActiveSupport::Notification event" do |fired_event|
  it "subscribes to #{fired_event}" do
    @tested_notification = false
    subscriber = ActiveSupport::Notifications.subscribe(fired_event) { |_, _| @tested_notification = true }

    command.call

    expect(@tested_notification).to eq(true)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    ActiveSupport::Notifications.unsubscribe(subscriber)
    raise e
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end

shared_examples "does not fire an ActiveSupport::Notification event" do |fired_event|
  it "subscribes to #{fired_event}" do
    @tested_notification = false
    subscriber = ActiveSupport::Notifications.subscribe(fired_event) { |_, _| @tested_notification = true }

    command.call

    expect(@tested_notification).to eq(false)
  rescue RSpec::Expectations::ExpectationNotMetError => e
    ActiveSupport::Notifications.unsubscribe(subscriber)
    raise e
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber)
  end
end
