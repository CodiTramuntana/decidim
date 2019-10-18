# frozen_string_literal: true

module Decidim
  class OnlyVerifiedVotesController < Decidim::ApplicationController
    include Devise::Controllers::Helpers
    include FormFactory

    before_action :validate_verification_adapters!, only: [:new, :create]

    helper Decidim::AuthorizationFormHelper

    def new
      @form = form(OnlyVerifiedVotesForm).from_params(form_params)
    end

    def create
      @form = form(OnlyVerifiedVotesForm).from_params(form_params)

      OnlyVerifiedVote.call(@form) do
        on(:ok) do |user|
          flash[:notice] = I18n.t("impersonations.create.success", scope: "decidim.admin")
          sign_in(user)
          redirect_to @form.redirect_url
        end

        on(:invalid) do
          flash.now[:alert] = I18n.t("impersonations.create.error", scope: "decidim.admin")
          render :new
        end
      end
    end

    private

    def form_params
      {
        authorizations: authorization_handlers,
        component_id: params[:component_id] || params[:only_verified_votes][:component_id],
        redirect_url: params[:redirect_url] || params[:only_verified_votes][:redirect_url],
        votable_gid: params[:votable_gid] || params[:only_verified_votes][:votable_gid]
      }
    end

    def new_only_verified_user
      @new_only_verified_user ||= Decidim::User.new(
        organization: current_organization,
        managed: true,
        name: "only_verified_user"
      ) do |u|
        u.nickname = UserBaseEntity.nicknamize(u.name, organization: current_organization)
        u.admin = false
        u.roles = ["user_manager"] # Decidim::Admin::Permissions#user_manager?
        u.tos_agreement = true
      end
    end

    def authorization_handlers
      available_verification_adapters.map do |adapter|
        Decidim::AuthorizationHandler.handler_for(adapter.name, handler_params(adapter.name))
      end
    end

    def handler_params(handler_name)
      handler_params = params.dig(:only_verified_votes, :authorizations)
      return default_handler_params if handler_params.nil?

      handler_params = handler_params.values.find { |h| h["handler_name"] == handler_name }
      return default_handler_params if handler_params.nil?

      handler_params.merge(default_handler_params)
    end

    def default_handler_params
      { user: new_only_verified_user }
    end

    # Public: Available authorization handlers in order to conditionally
    # show the menu element.
    def available_verification_adapters
      Decidim::Verifications::Adapter.from_collection(
        current_organization.available_authorization_handlers
      ).select { |w| w.type == "direct" }
    end

    # We should validate that only 'direct' verification workflows are allowed.
    def validate_verification_adapters!
      return if available_verification_adapters.any? &&
                available_verification_adapters.all? { |w| w.type == "direct" }

      raise "Invalid verifications"
    end
  end
end
