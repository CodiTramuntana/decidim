# frozen_string_literal: true

class AddTosVersionToOrganization < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_organizations, :tos_version, :datetime
    Decidim::Organization.find_each do |organization|
      tos_version = Decidim::StaticPage.find_by(slug: "terms-and-conditions", organization: organization).updated_at
      organization.update(tos_version: tos_version)
    end
  end

  def down
    remove_columns :decidim_organizations, :tos_version
  end
end
