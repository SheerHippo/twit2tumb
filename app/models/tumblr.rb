class Tumblr < ActiveRecord::Base
  attr_accessible :oauth_token, :oauth_token_secret, :user_id
end
