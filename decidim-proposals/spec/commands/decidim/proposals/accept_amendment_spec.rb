# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Accept do
      let!(:component) { create(:proposal_component) }
      let!(:proposal) { create(:proposal, component: component) }
      let!(:emendation) { create(:proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: proposal, emendation: emendation }
      let(:form) { Decidim::Amendable::ReviewForm.from_params(params) }
      let(:command) { described_class.new(form) }

      describe "call" do
        let(:params) do
          {
            id: amendment.id,
            title: emendation.title,
            body: emendation.body
          }
        end

        it "broadcasts ok" do
          expect do
            expect { command.call }.to broadcast(:ok)
          end.to change { Decidim::Amendment.count }.by(0)
          expect(emendation.amendment.state).to eq("accepted")
          expect(emendation.state).to eq("accepted")
          expect(proposal.coauthorships.count).to eq(2)
        end
      end
    end
  end
end
