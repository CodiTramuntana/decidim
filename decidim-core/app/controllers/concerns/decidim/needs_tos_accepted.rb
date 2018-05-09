# frozen_string_literal: true

module Decidim
  # Shared behaviour for controllers that need an organization present in order
  # to work. The organization is injected via the CurrentOrganization
  # middleware.
  module NeedsTosAccepted
    def check_tos_lastest_accepted
      return if tos_accepted?
      return if request.path == tos_path
      return if request.path == decidim.accept_tos_path
      return if request.path == decidim.delete_account_path

      redirect_to_tos unless tos_accepted?
    end

    private

    def tos_page
      @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: current_organization)
    end

    def tos_path
      decidim.page_path tos_page
    end

    def tos_path_w_params
      decidim.page_path tos_page, latest_tos_accepted: false
    end

    def tos_accepted?
      return true unless current_user
      current_user.tos_accepted_at >= current_organization.tos_updated_at
    end

    def redirect_to_tos
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path_w_params
    end
  end
end
