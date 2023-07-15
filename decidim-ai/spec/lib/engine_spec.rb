# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      describe ".create_reporting_users" do
        let!(:organization) { create(:organization) }

        it "successfully creates user" do
          expect { Decidim::Tools::Ai.create_reporting_users }.to change(Decidim::User, :count).by(1)
          expect(Decidim::User.where(email: Decidim::Tools::Ai.reporting_user_email).count).to eq(1)
        end
      end
    end
  end
end
