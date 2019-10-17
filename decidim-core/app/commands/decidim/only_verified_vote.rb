# frozen_string_literal: true

module Decidim
  # A command with all the business logic to impersonate a managed user.
  class OnlyVerifiedVote < Rectify::Command
    # Public: Initializes the command.
    #
    # form         - The form with the authorization info
    # user         - The user to impersonate
    def initialize(form)
      @form = form
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if the impersonation is not valid.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless @form.valid?

      transaction do
        user.save!

        create_authorizations

        create_impersonation_log
      end

      enqueue_expire_job

      broadcast(:ok)
    end

    private

    def user
      @form.authorizations.first.user
    end

    def component
      @component ||= Decidim::Component.find(@form.component_id)
    end

    def create_authorizations
      @form.authorizations.each { |handler| Authorization.create_or_update_from(handler) }
    end

    def create_impersonation_log
      Decidim::ImpersonationLog.create!(
        admin: @form.current_user,
        user: user,
        reason: @form.reason,
        started_at: Time.current
      )
    end

    def enqueue_expire_job
      Decidim::Admin::ExpireImpersonationJob
        .set(wait: Decidim::ImpersonationLog::SESSION_TIME_IN_MINUTES.minutes)
        .perform_later(user, @form.current_user)
    end
  end
end
