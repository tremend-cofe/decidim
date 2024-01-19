# frozen_string_literal: true

require "decidim/components/namer"
require "decidim/core/test/factories"
require "decidim/forms/test/factories"

FactoryBot.define do
  sequence(:private_key) do
    JWT::JWK.new(OpenSSL::PKey::RSA.new(4096))
  end

  factory :elections_component, parent: :component do
    transient do
      skip_injection { false }
    end
    name { generate_component_name(participatory_space.organization.available_locales, :elections, skip_injection:) }
    manifest_name { :elections }
    participatory_space { create(:participatory_process, :with_steps, organization:, skip_injection:) }
  end

  factory :election, class: "Decidim::Elections::Election" do
    transient do
      skip_injection { false }
      organization { build(:organization, skip_injection:) }
      number_of_votes { Faker::Number.number(digits: 2) }
      base_id { 10_000 }
    end

    upcoming
    title { generate_localized_title(:election_title, skip_injection:) }
    description { generate_localized_description(:election_description, skip_injection:) }
    end_time { 3.days.from_now }
    published_at { nil }
    blocked_at { nil }
    bb_status { nil }
    questionnaire
    component { create(:elections_component, organization:) }
    salt { SecureRandom.hex(32) }

    trait :bb_test do
      bb_status { "key_ceremony" }
      id { (base_id + Decidim::Elections::Election.bb_statuses.keys.index(bb_status)) }
    end

    trait :upcoming do
      start_time { 1.day.from_now }
    end

    trait :started do
      start_time { 2.days.ago }
    end

    trait :ongoing do
      started
      blocked_at { Time.current }
    end

    trait :finished do
      started
      end_time { 1.day.ago }
      blocked_at { Time.current }
    end

    trait :published do
      published_at { Time.current }
    end

    trait :complete do
      after(:build) do |election, evaluator|
        election.questions << build(:question, :yes_no, election:, weight: 1, skip_injection: evaluator.skip_injection)
        election.questions << build(:question, :candidates, election:, weight: 3, skip_injection: evaluator.skip_injection)
        election.questions << build(:question, :projects, election:, weight: 2, skip_injection: evaluator.skip_injection)
        election.questions << build(:question, :nota, election:, weight: 4, skip_injection: evaluator.skip_injection)
      end
    end

    trait :ready_for_setup do
      transient do
        trustee_keys { 3.times.to_h { [Faker::Name.name, generate(:private_key).export.to_json] } }
      end

      upcoming
      published
      complete

      after(:create) do |election, evaluator|
        evaluator.trustee_keys.each do |name, key|
          create(:trustee, :with_public_key, name:, election:, public_key: key, skip_injection: evaluator.skip_injection)
        end
      end
    end

    trait :created do
      ready_for_setup
      blocked_at { start_time - 1.day }

      start_time { 1.hour.from_now }
      bb_status { "created" }

      after(:create) do |election|
        trustees_participatory_spaces = Decidim::Elections::TrusteesParticipatorySpace.where(participatory_space: election.component.participatory_space)
        election.trustees << trustees_participatory_spaces.map(&:trustee)
      end
    end

    trait :key_ceremony do
      created
      bb_status { "key_ceremony" }
    end

    trait :key_ceremony_ended do
      key_ceremony
      bb_status { "key_ceremony_ended" }
    end

    trait :vote do
      key_ceremony_ended
      ongoing
      bb_status { "vote" }
    end

    trait :vote_ended do
      key_ceremony_ended
      ongoing
      finished
      bb_status { "vote_ended" }

      after(:create) do |election, evaluator|
        create_list(:vote, evaluator.number_of_votes, :accepted, election:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :tally_started do
      vote_ended
      bb_status { "tally_started" }
    end

    trait :tally_ended do
      tally_started
      bb_status { "tally_ended" }
      verifiable_results_file_hash { SecureRandom.hex(32) }
      verifiable_results_file_url { Faker::Internet.url }

      after(:create) do |election, evaluator|
        create(:bb_closure, :with_results, election:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :results_published do
      tally_ended
      bb_status { "results_published" }
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |election, evaluator|
        evaluator.photos_number.times do
          election.attachments << create(
            :attachment,
            :with_image,
            attached_to: election, skip_injection: evaluator.skip_injection
          )
        end
      end
    end
  end

  factory :question, class: "Decidim::Elections::Question" do
    transient do
      skip_injection { false }
      more_information { false }
      answers { 3 }
    end

    election
    title { generate_localized_title(:question_title, skip_injection:) }
    min_selections { 1 }
    max_selections { 1 }
    weight { Faker::Number.number(digits: 1) }
    random_answers_order { true }

    trait :complete do
      after(:build) do |question, evaluator|
        overrides = { question:, skip_injection: evaluator.skip_injection }
        overrides[:description] = nil unless evaluator.more_information
        question.answers = build_list(:election_answer, evaluator.answers, overrides)
      end
    end

    trait :yes_no do
      complete
      random_answers_order { false }
    end

    trait :candidates do
      complete
      max_selections { 6 }
      answers { 10 }
    end

    trait :projects do
      complete
      max_selections { 3 }
      answers { 6 }
      more_information { true }
    end

    trait :nota do
      complete
      max_selections { 4 }
      answers { 8 }
      min_selections { 0 }
    end

    trait :with_votes do
      after(:build) do |question, evaluator|
        overrides = { question:, skip_injection: evaluator.skip_injection }
        overrides[:description] = nil unless evaluator.more_information
        question.answers = build_list(:election_answer, evaluator.answers, :with_votes, overrides)
      end
    end
  end

  factory :election_answer, class: "Decidim::Elections::Answer" do
    transient do
      skip_injection { false }
    end
    question
    title { generate_localized_title(:election_answer_title, skip_injection:) }
    description { generate_localized_description(:election_answer_description, skip_injection:) }
    weight { Faker::Number.number(digits: 1) }
    selected { false }

    trait :with_votes do
      after(:build) do |answer, evaluator|
        create(:election_result, election: answer.question.election, question: answer.question, answer:, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_photos do
      transient do
        photos_number { 2 }
      end

      after :create do |election, evaluator|
        evaluator.photos_number.times do
          election.attachments << create(
            :attachment,
            :with_image,
            attached_to: election,
            skip_injection: evaluator.skip_injection
          )
        end
      end
    end
  end

  factory :bb_closure, class: "Decidim::Elections::BulletinBoardClosure" do
    transient do
      skip_injection { false }
    end
    initialize_with do
      Decidim::Elections::BulletinBoardClosure.find_or_create_by(
        decidim_elections_election_id: election.id
      )
    end

    election { create(:election, :complete, skip_injection:) }

    trait :with_results do
      after :create do |closure, evaluator|
        total_votes = closure.election.votes.count
        closure.election.questions.each do |question|
          max = total_votes
          question.answers.each do |answer|
            value = Faker::Number.between(from: 0, to: max)
            closure.results << create(:election_result, election: closure.election, question:, answer:, value:, skip_injection: evaluator.skip_injection)
            max -= value
          end
          closure.results << create(:election_result, :blank_ballots, election: closure.election, question:, value: max, skip_injection: evaluator.skip_injection)
        end
        closure.results << create(:election_result, :total_ballots, election: closure.election, value: total_votes, skip_injection: evaluator.skip_injection)
      end
    end
  end

  factory :election_result, class: "Decidim::Elections::Result" do
    transient do
      skip_injection { false }
      election { create(:election, :tally_ended, skip_injection:) }
    end

    closurable { create :bb_closure, election:, skip_injection: }
    question { create :question, election:, skip_injection: }
    answer { create :election_answer, question:, skip_injection: }
    value { Faker::Number.number(digits: 1) }
    result_type { "valid_answers" }

    trait :null_ballots do
      result_type { "null_ballots" }
      answer { nil }
    end

    trait :blank_ballots do
      result_type { "blank_ballots" }
      answer { nil }
    end

    trait :total_ballots do
      result_type { "total_ballots" }
      answer { nil }
      question { nil }
    end
  end

  factory :action, class: "Decidim::Elections::Action" do
    transient do
      skip_injection { false }
    end
    election
    message_id { "a.message+id" }
    status { :pending }
    action { :start_key_ceremony }
  end

  factory :trustee, class: "Decidim::Elections::Trustee" do
    transient do
      skip_injection { false }
      election { nil }
    end

    public_key { nil }
    user { build(:user, :confirmed, organization:, skip_injection:) }
    organization { create(:organization, skip_injection:) }

    trait :considered do
      after(:build) do |trustee, evaluator|
        trustee.trustees_participatory_spaces << build(:trustees_participatory_space, trustee:, election: evaluator.election, organization: evaluator.organization,
                                                                                      skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_elections do
      after(:build) do |trustee, evaluator|
        trustee.elections << build(:election, :upcoming, organization: evaluator.organization, skip_injection: evaluator.skip_injection)
      end
    end

    trait :with_public_key do
      considered
      name { Faker::Name.unique.name }
      public_key { generate(:private_key).export.to_json }
    end
  end

  factory :trustees_participatory_space, class: "Decidim::Elections::TrusteesParticipatorySpace" do
    transient do
      skip_injection { false }
      organization { election&.component&.participatory_space&.organization || create(:organization, skip_injection:) }
      election { nil }
    end
    participatory_space { election&.component&.participatory_space || create(:participatory_process, organization:, skip_injection:) }
    considered { true }
    trustee { create(:trustee, organization:, skip_injection:) }

    trait :trustee_ready do
      association :trustee, :with_public_key
    end
  end

  factory :vote, class: "Decidim::Elections::Vote" do
    transient do
      skip_injection { false }
    end
    election { create(:election, skip_injection:) }
    sequence(:voter_id) { |n| "voter_#{n}" }
    encrypted_vote_hash { "adf89asd0f89das7f" }
    status { "pending" }
    message_id { "decidim-test-authority.2.vote.cast+v.5826de088371d1b15b38f00c8203871caec07041ed0c8fb0c6fb875f0df763b6" }
    user { build(:user) }
    email { "an_email@example.org" }

    trait :accepted do
      status { "accepted" }
    end
  end
end
