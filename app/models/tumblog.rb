class Tumblog < ActiveRecord::Base
  attr_accessible :oauth_secret, :oauth_token, :user_id
end
