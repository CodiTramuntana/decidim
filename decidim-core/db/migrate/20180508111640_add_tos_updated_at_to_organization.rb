class AddTosUpdatedAtToOrganization < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_organizations, :tos_updated_at, :datetime
    execute("UPDATE decidim_organizations SET tos_updated_at = NOW()")
  end

  def down
    remove_columns :decidim_organizations, :confirmation_token, :tos_updated_at
  end
end
