# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe ReviewForm do
      subject { form }

      let(:resource) { create(:dummy_resource) }
      let(:amender) { create :user, :confirmed, organization: resource.organization }
      let(:amendable) { create(:proposal) }
      let(:emendation) { create(:proposal) }
      let(:amendment) { create :amendment, amender: emendation.creator_author, amendable: amendable, emendation: emendation }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:title) { "Loura Hansen II 1" }
      let(:body) { "Dlksdjfklesjfklew lkdjflksdjflk sdlkfjsdlkfjskdjf lskdfj skjflk sjflksdjf lksjflksdjflks jflksd jlkdsjlckjksd" }

      let(:form_params) do
        {
          amendable_gid: resource.to_sgid.to_s,
          id: amendment.id,
          title: title,
          body: body,
          component: resource.component
        }
      end

      let(:form_context) do
        {
          current_organization: resource.organization,
          current_participatory_space: resource.participatory_space,
          current_component: resource.component
        }
      end

      context "when everything is OK" do
        it { is_expected.to be_valid }
      end

      context "when the title is empty" do
        let(:form_params) do
          {
            amendable_gid: resource.to_sgid.to_s,
            id: amendment.id,
            title: nil,
            body: body,
            component: resource.component
          }
        end

        it { is_expected.to be_invalid }
      end

      context "when the body is empty" do
        let(:form_params) do
          {
            amendable_gid: resource.to_sgid.to_s,
            id: amendment.id,
            title: title,
            body: nil,
            component: resource.component
          }
        end

        it { is_expected.to be_invalid }
      end
    end
  end
end
