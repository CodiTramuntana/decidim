# frozen_string_literal: true

module Decidim
  # A Helper to render:
  # - the TOS updated announcement when redirected to the TOS page.
  # - the Accept updated TOS form in the TOS page.
  # - the Modal with info when refusing the updated TOS.
  module TosPageHelper
    # Renders the Call To Action button. Link and text can be configured
    # per organization.

    def tos_page_announcement
      return unless current_user
      return if current_user.tos_accepted?
      locals = {
        callout_class: "warning",
        announcement: {
          title: t("required_review.title", scope: "decidim.pages.terms_and_conditions"),
          body: t("required_review.body", scope: "decidim.pages.terms_and_conditions")
        }
      }
      html = render(partial: "decidim/shared/announcement", locals: locals).to_s
      html += %(<div id="sticky-top-stop"></div>).html_safe
      html.html_safe
    end

    def tos_page_sticky_form
      return unless current_user
      return if current_user.tos_accepted?
      html = %(
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
                <h5 class="card__title text-center">)
      html += t("form.legend", scope: "decidim.pages.terms_and_conditions")
      html += %(</h5>
      </div>

      <div class="row column flex-center">)
      html += tos_refuse_btn_modal

      lbl = t("form.agreement", scope: "decidim.pages.terms_and_conditions")
      html += button_to lbl, accept_tos_path, method: :put, class: "button button--nomargin small"

      html += %(
            </div>
          </div>
        </article>
        </div>
      </div>)
      html += tos_page_sticky_stop
      html.html_safe
    end

    def tos_page_sticky_stop
      %(<div id="sticky-btm-stop"></div>)
    end

    def tos_refuse_btn_modal
      modal_title = t("refuse.modal_title", scope: "decidim.pages.terms_and_conditions")
      btn_lbl_continue = t("refuse.modal_btn_continue", scope: "decidim.pages.terms_and_conditions")
      btn_lbl_exit = t("refuse.modal_btn_exit", scope: "decidim.pages.terms_and_conditions")
      btn_exit = button_to btn_lbl_exit, destroy_user_session_path, method: :delete, class: "clear button secondary button--nomargin small"
      btn_continue = button_to btn_lbl_continue, accept_tos_path, method: :put, class: "button button--nomargin small"
      %(
        <button class="clear button secondary button--nomargin small" type="button" data-open="tos-refuse-modal">
          #{t("refuse.modal_button", scope: "decidim.pages.terms_and_conditions")}
        </button>

        <div id="tos-refuse-modal" class="reveal" data-reveal aria-labelledby="#{modal_title}" aria-hidden="true" role="dialog">
          <h2>
          #{modal_title}
          </h2>

          <p>
            #{t("refuse.modal_body", scope: "decidim.pages.terms_and_conditions", data_portability_path: "#", delete_path: delete_account_path)}
          </p>

          <div class="row column flex-center">
            #{btn_exit}
            #{btn_continue}
          </div>
        </div>
      )
    end
  end
end
