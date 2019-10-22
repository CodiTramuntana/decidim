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
      return broadcast(:invalid) unless @form.valid? || existing_only_verified_user?

      transaction do
        user.save!

        create_authorizations

        update_user_extended_data
      end

      broadcast(:ok, user)
    end

    private

    def existing_only_verified_user?
      return unless @form.authorizations.map.all? do |authorization|
        authorization.send(:duplicates).any?
      end

      @user = User
              .managed
              .where(organization: current_organization)
              .find_by("extended_data @> ?", { unique_id: @form.unique_id }.to_json)
    end

    def user
      @user ||= @form.authorizations.first.user
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
          unique_id: @form.unique_id,
          session_expired_at: 30.minutes.from_now
        }
      )
    end
  end
end
