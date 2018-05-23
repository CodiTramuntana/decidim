# frozen_string_literal: true

class AddTosUpdatedAtToOrganization < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_organizations, :tos_version, :datetime
    execute("UPDATE decidim_organizations SET tos_version = NOW()")
  end

  def down
    remove_columns :decidim_organizations, :tos_version
  end
end
