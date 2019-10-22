# frozen_string_literal: true

module Decidim
  module Admin
    # This form handles a set of forms related to handling permissions
    # in the admin panel.
    class PermissionsForm < Form
      mimic :component_permissions

      attribute :component, Object
      attribute :permissions, Hash[String => PermissionForm]

      validate :vote_permissions_must_be_valid_with_only_verified_vote

      # Overriding Rectify::Form#form_attributes_valid?
      def form_attributes_valid?
        return false unless errors.empty? && permissions.each_value.map(&:errors).all?(&:empty?) # Preserves errors from custom validation methods

        super && permissions.values.all?(&:valid?)
      end

      def vote_permissions_must_be_valid_with_only_verified_vote
        return unless component&.settings&.only_verified_votes
        return unless (vote_permission_form = permissions["vote"])
        return if Decidim::Verifications::Adapter.from_collection(
          vote_permission_form.authorization_handlers.keys.reject(&:empty?)
        ).all? { |adapter| adapter.type == "direct" }

        vote_permission_form.errors.add(:base, :invalid_verifications)
      end
    end
  end
end
