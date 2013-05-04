require 'twitter'

class TweetsController < ApplicationController

	@key      = "HlHSnyfoBG4bF1PT4ugJg"
	@secret   = "BUfNXBwl7WpqJPCv0sebKOuilQGhRvfJQf6ec3E6GyI"
	@callback = "http://pure-hamlet-3918.herokuapp.com/twitter/oauth/callback"

	@base_url 			 = "https://api.twitter.com"
	@request_token_url   = "/oauth/request_token"
	@access_token_url 	 = "/oauth/access_token"
	@authorize_token_url = "/oauth/authorize"

  def self.consumer
		OAuth::Consumer.new(@key , @secret, 
							{:site 				 => @base_url,
							 :request_token_path => @request_token_url,
							 :access_token_path  => @access_token_url,
							 :authorize_path 	 => @authorize_token_url, 
							 :http_method 		 => :post} )
	end

	def oauth
		@request_token = TweetsController.consumer.get_request_token(:oauth_callback => @callback)
		session[:request_token] = @request_token.token
		session[:request_token_secret] = @request_token.secret
		#Send to twitter.com to authorize
		redirect_to @request_token.authorize_url
	end

	def callback
		@request_token = OAuth::RequestToken.new(TweetsController.consumer, session[:request_token], session[:request_token_secret])
		@access_token = @request_token.get_access_token
		twitter_user = Tweets.new({:user_id => 5, :oauth_token => @access_token.token, :oauth_secret => @access_token.secret})
		twitter_user.save
		redirect_to(root_path)
	end

	def show
		@user = Tweets.find_by_user_id(5)
	end
end
