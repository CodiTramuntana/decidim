# frozen_string_literal: true

class AddTosAcceptedAtFieldToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_users, :tos_accepted_at, :datetime
    execute("UPDATE decidim_users SET tos_accepted_at = NOW()")
  end

  def down
    remove_columns :decidim_users, :confirmation_token, :tos_accepted_at
  end
end
