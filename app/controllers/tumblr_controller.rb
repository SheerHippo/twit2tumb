class TumblrController < ApplicationController

	def self.consumer
		OAuth::Consumer.new("Sr6aNdQZveayHCvkCKH0RPN9mULpinm1gTdJPcbXcujOLHawaV", "Nr1LgaoTSa9BH8ZlPEonwYC78PnVc1fYdHT0DoswuWQXxGdCzE", {:site=>"https://www.tumblr.com",:request_token_path => "/oauth/request_token",:access_token_path => "/oauth/access_token",:authorize_path => "/oauth/authorize", :http_method => :post} )
	end

	def oauth
		@request_token = TumblrController.consumer.get_request_token(:oauth_callback => "localhost:3000/tumblr/oauth/callback")
		session[:request_token] = @request_token.token
		session[:request_token_secret] = @request_token.secret
		#Send to tumblr.com to authorize
		redirect_to @request_token.authorize_url
	end

	def callback
		@request_token = OAuth::RequestToken.new(UsersController.consumer, session[:request_token], session[:request_token_secret])
		@access_token = @request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
		tumblr_user = Tumblr.new(:access_token => @access_token.token)
		tumblr_user.save
	end
end
