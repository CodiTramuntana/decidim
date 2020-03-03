# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # Shared behaviour for controllers that need user impersonation logic.
  module OnlyVerifiedVotes
    extend ActiveSupport::Concern

    include ::Devise::Controllers::Helpers

    included do
      before_action :check_only_verified_session_expired

      private

      # Check if the active impersonation session has expired or not.
      def check_only_verified_session_expired
        return unless (user = real_user) &&
                      user.managed? &&
                      Time.zone.parse(user.extended_data["session_expired_at"]) < Time.current

        sign_out(user)
        flash[:alert] = I18n.t("managed_users.expired_session", scope: "decidim")
        redirect_to decidim.root_path
      end
    end
  end
end
