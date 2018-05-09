# frozen_string_literal: true

module Decidim
  # The controller to handle the current user's
  # Terms and Conditions agreement.
  class TosController < Decidim::ApplicationController
    helper TosPageHelper
    skip_before_action :store_current_location
    skip_authorization_check

    def accept_tos
      current_user.tos_accepted_at = Time.current
      if current_user.save!
        flash[:notice] = t("accept.success", scope: "decidim.pages.terms_and_conditions" )
        redirect_to after_sign_in_path_for current_user
      else
        flash[:alert] = t("accept.error", scope: "decidim.pages.terms_and_conditions" )
        redirect_to decidim.page_path tos_page
      end
    end

    def refuse_tos
      raise
      # redirect_to tos_page
    end
  end
end
