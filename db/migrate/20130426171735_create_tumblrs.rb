class CreateTumblrs < ActiveRecord::Migration
  def change
    create_table :tumblrs do |t|
      t.integer :user_id
      t.string :oauth_token
      t.string :oauth_token_secret

      t.timestamps
    end
  end
end
