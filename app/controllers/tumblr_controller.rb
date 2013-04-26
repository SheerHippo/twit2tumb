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
		@access_token = @request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
		tumblr_user = Tumblr.new({:user_id => 5, :oauth_token => @access_token.token, :oauth_secret => @access_token.secret})
		tumblr_user.save
		redirect_to(root_path)
	end
end
