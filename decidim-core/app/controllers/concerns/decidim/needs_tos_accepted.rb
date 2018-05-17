# frozen_string_literal: true

module Decidim
  # Shared behaviour for signed_in users that require the latest TOS accepted
  module NeedsTosAccepted
    def tos_accepted_by_user
      return if tos_accepted?
      return if permited_paths?

      redirect_to_tos
    end

    private

    def permited_paths?
      permited_paths = [tos_path, decidim.delete_account_path, decidim.accept_tos_path]
      case request.path
      when *permited_paths
        true
      else
        false
      end
    end

    def terms_and_conditions_page
      @terms_and_conditions_page ||= Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: current_organization)
    end

    def tos_path
      decidim.page_path terms_and_conditions_page
    end

    def tos_accepted?
      return true unless current_user
      return true if current_user.managed
      @tos_accepted ||= current_user.tos_accepted_at >= current_organization.tos_updated_at
    end

    def redirect_to_tos
      flash[:secondary] = t("required_review.alert", scope: "decidim.pages.terms_and_conditions")
      redirect_to tos_path
    end
  end
end
