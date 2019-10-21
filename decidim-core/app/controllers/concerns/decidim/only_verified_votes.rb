# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module OnlyVerifiedVotes
    extend ActiveSupport::Concern

    include Decidim::ComponentPathHelper

    included do
      before_action :check_allowed

      private

      # Check if the active impersonation session has expired or not.
      def check_allowed
        return unless (user = real_user) && user.name == "only_verified_user"
        return if allowed?(user)

        component_id = user.extended_data["component_id"]
        component = Decidim::Component.find(component_id)
        component_path = EngineRouter.main_proxy(component).root_path
        return if request.path == component_path

        flash[:alert] = t("actions.unauthorized", scope: "decidim.core")
        redirect_to component_path
      end

      # "action"=>"show", "authorization_action"=>"vote"
      # def allowed?(user)
      #   # byebug
      #   allowed_to?(
      #     params[:authorization_action] || params[:action],
      #     :only_verified,
      #     { component_id: params["component_id"] },
      #     [Decidim::Permissions],
      #     user
      #   )
      # end

      def allowed?(user)
        # byebug
        user.extended_data["component_id"] == params["component_id"] &&
          params[:action].in?(%w(index show)) ||
          params[:controller].in?(["decidim/proposals/proposal_votes",
                                   "decidim/budgets/line_items",
                                   "decidim/budgets/orders"])
      end
    end
  end
end
