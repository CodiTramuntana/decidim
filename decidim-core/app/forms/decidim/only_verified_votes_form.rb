# frozen_string_literal: true

module Decidim
  # A form object used to impersonate users from the admin dashboard.
  #
  # This form will contain a dynamic attribute for the user authorization.
  # This authorization will be selected by the admin user if more than one exists.
  class OnlyVerifiedVotesForm < Form
    attribute :authorizations, Array[AuthorizationHandler]

    # validates :authorizations, presence: true

    private

    def managed_user?
      user && user.managed?
    end
  end
end
