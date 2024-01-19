# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/forms/test/factories"

def format_birthdate(birthdate)
  format("%04d%02d%02d", birthdate.year, birthdate.month, birthdate.day)
end

def hash_for(*data)
  Digest::SHA256.hexdigest(data.join("."))
end

FactoryBot.define do
  sequence(:voting_slug) do |n|
    "#{Decidim::Faker::Internet.slug(words: nil, glue: "-")}-#{n}"
  end

  factory :voting, class: "Decidim::Votings::Voting" do
    transient do
      skip_injection { false }
    end
    organization
    slug { generate(:voting_slug) }
    title { generate_localized_title(:voting_title, skip_injection:) }
    description { generate_localized_description(:voting_description, skip_injection:) }
    published_at { Time.current }
    start_time { 1.day.from_now }
    end_time { 3.days.from_now }
    decidim_scope_id { create(:scope, organization:, skip_injection:).id }
    banner_image { Decidim::Dev.test_file("city2.jpeg", "image/jpeg") }
    introductory_image { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }
    voting_type { "hybrid" }
    census_contact_information { nil }
    show_check_census { true }

    trait :unpublished do
      published_at { nil }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :upcoming do
      start_time { 7.days.from_now }
      end_time { 1.month.from_now + 7.days }
    end

    trait :ongoing do
      start_time { 7.days.ago }
      end_time { 1.month.from_now - 7.days }
    end

    trait :finished do
      start_time { 1.month.ago - 7.days }
      end_time { 7.days.ago }
    end

    trait :promoted do
      promoted { true }
    end

    trait :online do
      voting_type { "online" }
    end

    trait :in_person do
      voting_type { "in_person" }
    end

    trait :hybrid do
      voting_type { "hybrid" }
    end

    trait :with_content_blocks do
      transient { blocks_manifests { [:hero] } }

      after(:create) do |voting, evaluator|
        evaluator.blocks_manifests.each do |manifest_name|
          create(
            :content_block,
            organization: voting.organization,
            scope_name: :voting_landing_page,
            manifest_name:,
            scoped_resource_id: voting.id,
            skip_injection: evaluator.skip_injection
          )
        end
      end
    end
  end

  factory :voting_election, parent: :election do
    transient do
      skip_injection { false }
      voting { create(:voting, skip_injection:) }
      base_id { 20_000 }
    end

    component { create(:elections_component, organization:, participatory_space: voting, skip_injection:) }
  end

  factory :polling_station, class: "Decidim::Votings::PollingStation" do
    transient do
      skip_injection { false }
    end
    title { generate_localized_title(:polling_station_title, skip_injection:) }
    location { generate_localized_description(:polling_station_location, skip_injection:) }
    location_hints { generate_localized_description(:polling_station_location_hints, skip_injection:) }
    address { Faker::Lorem.sentence(word_count: 3) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    voting { create(:voting, skip_injection:) }
  end

  factory :polling_officer, class: "Decidim::Votings::PollingOfficer" do
    transient do
      skip_injection { false }
    end
    user { create :user, organization: voting.organization, skip_injection: }
    voting { create :voting, skip_injection: }

    trait :president do
      presided_polling_station { create :polling_station, voting:, skip_injection: }
    end
  end

  factory :monitoring_committee_member, class: "Decidim::Votings::MonitoringCommitteeMember" do
    transient do
      skip_injection { false }
    end
    user
    voting { create :voting, organization: user.organization, skip_injection: }
  end

  factory :dataset, class: "Decidim::Votings::Census::Dataset" do
    transient do
      skip_injection { false }
    end
    voting { create(:voting) }
    filename { "file.csv" }
    status { "init_data" }
    csv_row_raw_count { 1 }
    csv_row_processed_count { 1 }

    trait :with_data do
      after(:create) do |dataset, evaluator|
        create_list(:datum, 5, dataset:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_access_code_data do
      after(:create) do |dataset, evaluator|
        create_list(:datum, 5, :with_access_code, dataset:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :data_created do
      status { "data_created" }
    end

    trait :codes_generated do
      with_access_code_data
      status { "codes_generated" }
    end

    trait :frozen do
      status { "freeze" }
    end
  end

  factory :datum, class: "Decidim::Votings::Census::Datum" do
    dataset

    transient do
      skip_injection { false }
      document_number { Faker::IDNumber.spanish_citizen_number }
      document_type { %w(identification_number passport).sample }
      birthdate { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end

    hashed_in_person_data { hash_for(document_number, document_type, format_birthdate(birthdate)) }
    hashed_check_data { hash_for(document_number, document_type, format_birthdate(birthdate), postal_code) }

    full_name { Faker::Name.name }
    full_address { Faker::Address.full_address }
    postal_code { Faker::Address.postcode }
    mobile_phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.email }

    trait :with_access_code do
      access_code { Faker::Alphanumeric.alphanumeric(number: 8) }
      hashed_online_data { hash_for hashed_check_data, access_code }
    end
  end

  factory :ballot_style, class: "Decidim::Votings::BallotStyle" do
    transient do
      skip_injection { false }
    end
    code { Faker::Lorem.word.upcase }
    voting { create(:voting, skip_injection:) }

    trait :with_questions do
      transient do
        election { create(:election, :complete, component: create(:elections_component, participatory_space: voting, skip_injection:), skip_injection:) }
      end
    end

    trait :with_ballot_style_questions do
      with_questions

      after(:create) do |ballot_style, evaluator|
        evaluator.election.reload.questions.first(2).map { |question| create(:ballot_style_question, question:, ballot_style:, skip_injection: evaluator.skip_injection) }
      end
    end
  end

  factory :ballot_style_question, class: "Decidim::Votings::BallotStyleQuestion" do
    transient do
      skip_injection { false }
    end
    question
    ballot_style
  end

  factory :in_person_vote, class: "Decidim::Votings::InPersonVote" do
    transient do
      skip_injection { false }
      voting { create(:voting, skip_injection:) }
      component { create(:elections_component, participatory_space: voting, skip_injection:) }
    end

    election { create(:election, component:, skip_injection:) }
    sequence(:voter_id) { |n| "voter_#{n}" }
    status { "pending" }
    message_id { "decidim-test-authority.2.vote.in_person+v.5826de088371d1b15b38f00c8203871caec07041ed0c8fb0c6fb875f0df763b6" }
    polling_station { polling_officer.polling_station }
    polling_officer { create(:polling_officer, :president, voting:, skip_injection:) }

    trait :accepted do
      status { "accepted" }
    end

    trait :rejected do
      status { "rejected" }
    end
  end

  factory :ps_closure, class: "Decidim::Votings::PollingStationClosure" do
    transient do
      skip_injection { false }
      number_of_votes { Faker::Number.number(digits: 2) }
    end

    election { create(:voting_election, :complete, skip_injection:) }
    polling_station { polling_officer.polling_station }
    polling_officer { create(:polling_officer, :president, voting: election.participatory_space, skip_injection:) }
    polling_officer_notes { Faker::Lorem.paragraph }
    monitoring_committee_notes { nil }
    signed_at { nil }
    phase { :count }
    validated_at { nil }

    trait :completed do
      phase { :complete }
    end

    trait :with_results do
      phase { :signature }

      after :create do |closure, evaluator|
        total_votes = evaluator.number_of_votes
        create_list(:in_person_vote, evaluator.number_of_votes, :accepted, voting: closure.election.participatory_space, election: closure.election,
                                                                           skip_injection: evaluator.skip_injection)

        closure.election.questions.each do |question|
          max = total_votes
          question.answers.each do |answer|
            value = Faker::Number.between(from: 0, to: max)
            closure.results << create(:election_result, closurable: closure, election: closure.election, question:, answer:, value:, skip_injection: evaluator.skip_injection)
            max -= value
          end
          value = Faker::Number.between(from: 0, to: max)
          closure.results << create(:election_result, :null_ballots, election: closure.election, question:, value:, skip_injection: evaluator.skip_injection)
          max -= value
          closure.results << create(:election_result, :blank_ballots, election: closure.election, question:, value: max, skip_injection: evaluator.skip_injection)
        end
        closure.results << create(:election_result, :total_ballots, closurable: closure, election: closure.election, value: total_votes, skip_injection: evaluator.skip_injection)
      end
    end
  end
end
