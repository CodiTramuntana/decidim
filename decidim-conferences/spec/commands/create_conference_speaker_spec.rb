# frozen_string_literal: true

require "spec_helper"

module Decidim::Conferences
  describe Admin::CreateConferenceSpeaker do
    subject { described_class.new(form, current_user, conference) }

    let(:conference) { create(:conference) }
    let(:user) { nil }
    let!(:current_user) { create :user, :confirmed, organization: conference.organization }
    let(:meeting_component) do
      create(:component, manifest_name: :meetings, participatory_space: conference)
    end

    let(:meetings) do
      create_list(
        :meeting,
        3,
        component: meeting_component
      )
    end
    let(:meeting_ids) { meetings.map(&:id) }
    let(:avatar) { Decidim::Dev.test_file("avatar.jpg", "image/jpeg") }
    let(:form) do
      instance_double(
        Admin::ConferenceSpeakerForm,
        invalid?: invalid,
        full_name: "Full name",
        user: user,
        errors: ActiveModel::Errors.new(Admin::ConferenceSpeakerForm),
        attributes: {
          full_name: "Full name",
          position: { en: "position" },
          affiliation: { en: "affiliation" },
          short_bio: Decidim::Faker::Localized.sentence(word_count: 5),
          twitter_handle: "full_name",
          personal_url: Faker::Internet.url,
          meeting_ids: meeting_ids,
          avatar: avatar
        }
      )
    end

    let(:invalid) { false }

    context "when the form is not valid" do
      let(:invalid) { true }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end

      context "when image is invalid" do
        let(:invalid) { false }

        let(:avatar) { Decidim::Dev.test_file("invalid.jpeg", "image/jpeg") }

        before do
          Decidim::AvatarUploader.enable_processing = true
        end

        it "prevents uploading" do
          expect { subject.call }.not_to raise_error
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    context "when everything is ok" do
      let(:conference_speaker) { Decidim::ConferenceSpeaker.last }

      it "creates an conference" do
        expect { subject.call }.to change { Decidim::ConferenceSpeaker.count }.by(1)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "sets the conference" do
        subject.call
        expect(conference_speaker.conference).to eq conference
      end

      it "traces the action", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:create, Decidim::ConferenceSpeaker, current_user, hash_including(resource: hash_including(:title)))
          .and_call_original

        expect { subject.call }.to change(Decidim::ActionLog, :count)
        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
      end

      context "with an existing user in the platform" do
        let!(:user) { create(:user, organization: conference.organization) }

        it "sets the user" do
          subject.call
          expect(conference_speaker.user).to eq user
        end
      end

      it "links meetings" do
        subject.call

        conference_meetings = []
        meetings.each do |meeting|
          conference_meetings << meeting.becomes(Decidim::ConferenceMeeting)
        end

        conference_speaker.conference_meetings = conference_meetings
        expect(conference_speaker.conference_meetings).to match_array(conference_meetings)
      end
    end
  end
end
