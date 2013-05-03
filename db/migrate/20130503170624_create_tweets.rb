class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.string :oauth_secret
      t.string :oauth_token
      t.integer :user_id

      t.timestamps
    end
  end
end
