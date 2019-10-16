# frozen_string_literal: true

module Decidim
  class OnlyVerifiedVotesController < Decidim::ApplicationController
    helper_method :handler, :unauthorized_methods
    layout false

    def create; end

    private

    def votable_resource
      @votable_resource ||= GlobalID::Locator.locate_signed(params[:votable_gid])
    end

    def current_component
      @current_component ||= Decidim::Component.find(params[:component_id])
    end

    def unauthorized_methods
      @unauthorized_methods ||= available_verification_workflows.reject do |handler|
        active_authorization_methods.include?(handler.key)
      end
    end

    def active_authorization_methods
      Verifications::Authorizations.new(organization: current_organization).pluck(:name)
    end

    # Public: Available authorization handlers in order to conditionally
    # show the menu element.
    def available_verification_workflows
      Verifications::Adapter.from_collection(
        current_organization.available_authorizations & Decidim.authorization_workflows.map(&:name)
      )
    end
  end
end
