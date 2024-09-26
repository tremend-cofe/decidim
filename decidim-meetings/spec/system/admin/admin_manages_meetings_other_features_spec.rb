# frozen_string_literal: true

require "spec_helper"

describe "Admin manages meetings other features", serves_geocoding_autocomplete: true, serves_map: true do
  let(:manifest_name) { "meetings" }
  let!(:meeting) { create(:meeting, :published, scope:, services: [], component: current_component) }

  before do
    # Make static map requests not to fail with HTTP 500 (causes JS error)
    stub_request(:get, Regexp.new(Decidim.maps.fetch(:static).fetch(:url))).to_return(body: "")
  end

  include_context "when managing a component as an admin"

  it_behaves_like "manage registrations"
  it_behaves_like "manage announcements"
  it_behaves_like "manage agenda"
  it_behaves_like "manage invites"
  it_behaves_like "export meetings"
  it_behaves_like "duplicate meetings"
end
