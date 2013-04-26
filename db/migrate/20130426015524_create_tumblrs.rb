class CreateTumblrs < ActiveRecord::Migration
  def change
    create_table :tumblrs do |t|
      t.integer :user_id
      t.string :access_token

      t.timestamps
    end
  end
end
