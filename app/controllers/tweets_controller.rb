require 'twitter'

class TweetsController < ApplicationController
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
		#Send to tumblr.com to authorize
		redirect_to @request_token.authorize_url
	end

	def callback
		@request_token = OAuth::RequestToken.new(TumblogController.consumer, session[:request_token], session[:request_token_secret])
		@access_token = @request_token.get_access_token
		tumblr_user = Tumblog.new({:user_id => 5, :oauth_token => @access_token.token, :oauth_secret => @access_token.secret})
		tumblr_user.save
		redirect_to(root_path)
	end

	def show
		@user = Tumblog.find_by_user_id(5)
	end
end
