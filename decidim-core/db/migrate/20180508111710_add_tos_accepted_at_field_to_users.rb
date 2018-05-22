# frozen_string_literal: true

class AddTosAcceptedAtFieldToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_users, :accepted_tos_version, :datetime
    execute("UPDATE decidim_users SET accepted_tos_version = NOW()")
  end

  def down
    remove_columns :decidim_users, :accepted_tos_version
  end
end
