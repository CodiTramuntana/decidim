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
      return broadcast(:invalid) unless @form.valid? # && new_only_verified_user?

      transaction do
        user.save!

        create_authorizations

        update_user_extended_data

        # delete_authorizations

        create_impersonation_log
      end

      enqueue_expire_job

      broadcast(:ok, user)
    end

    private

    def new_only_verified_user?
      return true if Decidim::User
                     .managed
                     .where(organization: current_organization)
                     .where("extended_data @> ?", { unique_id: @form.unique_id }.to_json)
                     .empty?

      @form.authorizations.each do |authorization|
        authorization.errors.add(:base, I18n.t("decidim.authorization_handlers.errors.duplicate_authorization"))
      end

      false
    end

    def user
      @form.authorizations.first.user
    end

    def create_authorizations
      @form.authorizations.each { |handler| Authorization.create_or_update_from(handler) }
    end

    def authorizations
      Verifications::Authorizations.new(
        organization: current_organization,
        user: user,
        granted: true
      ).query
    end

    def update_user_extended_data
      user.update(
        extended_data: {
          component_id: @form.component_id,
          authorizations: authorizations.as_json(only: [:name, :granted_at, :metadata, :unique_id]),
          unique_id: @form.unique_id
        }
      )
    end

    def delete_authorizations
      authorizations.delete_all
    end

    def create_impersonation_log
      Decidim::ImpersonationLog.create!(
        admin: user,
        user: user,
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
