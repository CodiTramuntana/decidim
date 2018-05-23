# frozen_string_literal: true

class AddAcceptedTosVersionFieldToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_users, :accepted_tos_version, :datetime
    Decidim::Organization.find_each do |organization|
      tos_version = Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization).updated_at
      # rubocop:disable Rails/SkipsModelValidations
      organization.users.update_all(accepted_tos_version: tos_version)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def down
    remove_columns :decidim_users, :accepted_tos_version
  end
end
