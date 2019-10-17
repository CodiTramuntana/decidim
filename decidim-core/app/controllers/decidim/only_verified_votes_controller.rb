# frozen_string_literal: true

module Decidim
  class OnlyVerifiedVotesController < Decidim::ApplicationController
    include FormFactory

    helper_method :handler, :unauthorized_methods
    before_action :valid_verification_workflows, only: [:new, :create]
    layout false

    helper Decidim::AuthorizationFormHelper

    def new
      @form = form(OnlyVerifiedVotesForm).from_params(
        authorizations: authorization_handlers
      )
    end


    def create
      # raise
    end

    private

    def votable_resource
      @votable_resource ||= GlobalID::Locator.locate_signed(params[:votable_gid])
    end

    def current_component
      @current_component ||= Decidim::Component.find(params[:component_id])
    end

    def unauthorized_methods
      @unauthorized_methods ||= available_verification_workflows
    end

    def new_only_verified_user
      Decidim::User.new(
        organization: current_organization,
        managed: true,
        name: "new_only_verified_user"
      ) do |u|
        u.nickname = UserBaseEntity.nicknamize(u.name, organization: current_organization)
        u.admin = false
        u.tos_agreement = true
        u.extended_data = {only_verified: true}
      end
    end

    def authorization_handlers
      available_verification_workflows.map do |workflow|
        Decidim::AuthorizationHandler.handler_for(
          workflow.name,
          {user: new_only_verified_user}
        )
      end
    end

    # Public: Available authorization handlers in order to conditionally
    # show the menu element.
    def available_verification_workflows
      Decidim::Verifications::Adapter.from_collection(
        current_organization.available_authorization_handlers
      ).select{|w| w.type == "direct"}
    end

    # We should validate that only 'direct' verification workflows are allowed.
    def valid_verification_workflows
      return if available_verification_workflows.any? &&
        available_verification_workflows.all?{|w| w.type == "direct"}

      raise "Invalid workflows"
    end
  end
end
