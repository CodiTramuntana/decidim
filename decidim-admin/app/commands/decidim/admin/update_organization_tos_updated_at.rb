# frozen_string_literal: true

module Decidim
  module Admin
    # A command with the business logic for updating the current
    # organization tos_updated_at attribute.
    class UpdateOrganizationTosUpdatedAt < Rectify::Command
      # Public: Initializes the command.
      #
      # organization - The Organization that will be updated.
      # page - A static_page instance.
      # form - A form object with the params.
      def initialize(organization, page, form)
        @organization = organization
        @page = page
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.nil?

        update_organization_tos_updated_at
        broadcast(:ok)
      end

      private

      attr_reader :form

      def update_organization_tos_updated_at
        Decidim.traceability.update!(
          @organization,
          @form.current_user,
          tos_updated_at: @page.updated_at
        )
      end
    end
  end
end
