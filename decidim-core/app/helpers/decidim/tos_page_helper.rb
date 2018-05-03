# frozen_string_literal: true

module Decidim
  # A Helper to render the Call To Action button.
  module TosPageHelper
    # Renders the Call To Action button. Link and text can be configured
    # per organization.


    def tos_page_announcement
      return unless tos_page?
      locals = {
        callout_class: "secondary",
        announcement: {
          title: t("required_review.title", scope: "decidim.pages.terms_and_conditions"),
          body: t("required_review.body", scope: "decidim.pages.terms_and_conditions")
        }
      }
      html = render(partial: "decidim/shared/announcement", locals: locals).to_s
      html += %{<div id="sticky-top-stop"></div>}.html_safe
      html.html_safe
    end

    def tos_page_sticky_form
      return unless tos_page?
            html = %{
      <div data-sticky-container>
        <div class="sticky"
              data-sticky
              data-stick-to="bottom"
              data-margin-bottom="0"
              data-top-anchor="sticky-top-stop:top"
              data-btm-anchor="sticky-btm-stop:top"
              data-sticky-on="small">
        <article class="card">
          <div class="card__content">
            <div class="card__header">
                <h5 class="card__title text-center">}
                html += t("form.legend", scope:"decidim.pages.terms_and_conditions")
                html += %{</h5>
            </div>

            <div class="row column flex-center">}
              html += tos_refuse_btn_dropdown

              lbl = t("form.agreement", scope:"decidim.pages.terms_and_conditions")
              html += button_to lbl, accept_tos_path, {method: :put, class: "button button--nomargin small"}

              html += %{
            </div>
          </div>
        </article>
        </div>
      </div>}
      html += tos_page_sticky_stop
      html.html_safe
    end

    def tos_page_sticky_stop
      %Q{<div id="sticky-btm-stop"></div>}
    end

    def tos_refuse_btn_dropdown
      %{
        <button class="clear button secondary button--nomargin small" type="button" data-toggle="tos-refuse-dropdown">
        #{t("refuse.dropdown_button", scope:"decidim.pages.terms_and_conditions")}
        </button>

        <div class="dropdown-pane top" id="tos-refuse-dropdown" data-dropdown>
          #{t("refuse.dropdown_info_text", scope:"decidim.pages.terms_and_conditions", data_portability_path: "#", delete_path: delete_account_path)}
        </div>
      }
    end

    private

    def tos_page?
      @page_finder.page.slug == "terms-and-conditions"
    end
  end
end
