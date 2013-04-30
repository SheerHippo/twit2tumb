class TumblogController < ApplicationController

	@key      = "Sr6aNdQZveayHCvkCKH0RPN9mULpinm1gTdJPcbXcujOLHawaV"
	@secret   = "Nr1LgaoTSa9BH8ZlPEonwYC78PnVc1fYdHT0DoswuWQXxGdCzE"
	@callback = "localhost:3000/tumblr/oauth/callback"

	@base_url 			 = "https://www.tumblr.com"
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
		@request_token = TumblogController.consumer.get_request_token(:oauth_callback => @callback)
		session[:request_token] = @request_token.token
		session[:request_token_secret] = @request_token.secret
		#Send to tumblr.com to authorize
		redirect_to @request_token.authorize_url
	end

	def callback
		@request_token = OAuth::RequestToken.new(TumblogController.consumer, session[:request_token], session[:request_token_secret])
		@access_token = @request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
		tumblr_user = Tumblog.new({:user_id => 5, :oauth_token => @access_token.token, :oauth_secret => @access_token.secret})
		tumblr_user.save
		redirect_to(root_path)
	end

	def show
		@user = Tumblog.find_by_user_id(5)
	end

	def post
		@user = Tumblog.find_by_user_id(5)
		@client = Tumblr::Client.new(:consumer_key => @key, :consumer_secret => @secret, :oauth_token => @user.oauth_token, :oauth_token_secret => @user.oauth_secret)
		@client.text("sheerhippo.tumblr.com", :body => "test", :state => "draft")
		redirect_to "http://www.tumblr.com/blog/sheerhippo/drafts"
	end
end