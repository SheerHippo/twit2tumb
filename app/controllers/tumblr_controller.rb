require "excon"
require "cgi"
require "base64"
require "openssl"
require "digest/hmac"
require "json/pure"

class TumblrController < ApplicationController

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
		@request_token = TumblrController.consumer.get_request_token(:oauth_callback => @callback)
		session[:request_token] = @request_token.token
		session[:request_token_secret] = @request_token.secret
		#Send to tumblr.com to authorize
		redirect_to @request_token.authorize_url
	end

	def callback
		@request_token = OAuth::RequestToken.new(TumblrController.consumer, session[:request_token], session[:request_token_secret])
		@access_token = @request_token.get_access_token({:oauth_verifier => params[:oauth_verifier]})
		tumblr_user = Tumblr.new({:user_id => 5, :oauth_token => @access_token.token, :oauth_token_secret => @access_token.secret})
		tumblr_user.save
		redirect_to(root_path)
	end

	def show
		@user = Tumblr.find_by_user_id(5)
	end

	def post
		url = "api.tumblr.com/v2/blog/sheerhippo.tumblr.com/post"
		@user = Tumblr.find_by_user_id(5)
		method = :post

		authentication, params = generate_authentication_hash({ :oauth_token => @user.oauth_token }), { :alt => "jsonc" }
      	authentication.merge! oauth_signature(secret_string(@secret, @user.oauth_token_secret), method, url, authentication, params)

		data = {
			:type   => "text",
			:state  => "draft",
			:tags   => "tags, tags",
			:tweet  => "off",
			:format => "html",
			:body 	=> "Testing"
		}

		body = { :data => data }.to_json

		headers = {
        	"Authorization" => authorization_string(authentication),
        	# "GData-Version" => "2", # http://code.google.com/apis/calendar/data/2.0/developers_guide_protocol.html#Versioning
        	# "Accept" => "application/json"
      	}

		Excon.send(method, url + "?" + normalize_parameters(params), :body => body, :headers => hash.merge(headers))
	end

	private
		def generate_authentication_hash(hash = {})
			{
				:oauth_consumer_key 	=> @key,
				:oauth_nonce			=> nonce,
				:oauth_signature_method => "HMAC-SHA1",
				:oauth_timestamp		=> timestamp,
				:oauth_version			=> "1.0"
			}.merge(hash)
		end

		def nonce
			Digest::MD5.hexdigest(rand.to_s)
		end

		def timestamp
			Time.now.to_i.to_s
		end

		def oauth_signature(secret, method, url, authentication, params = {})
 			{ :oauth_signature => sign(secret, generate_signature_base(method, url, normalize_parameters(authentication.merge(params)))) }
 		end

  		def generate_signature_base(method, url, param_string)
   			[method.to_s.upcase, CGI.escape(url), CGI.escape(param_string)].join("&")
  		end
  
  		def sign(secret, string)
   			Base64.encode64(OpenSSL::HMAC.digest("sha1", secret, string)).strip
 		end
 
 		def normalize_parameters(params)
   			params.sort.inject("") { |str, (key, value)| str + "#{CGI.escape(key.to_s)}=#{CGI.escape(value)}&" }[0..-2]
 		end
 
 		def secret_string(secret, token_secret)
   			"#{secret}&#{token_secret}"
 		end

 		def authorization_string(params)
  			"OAuth " + params.sort.map { |key, value| "#{key}=\"#{CGI.escape(value)}\"" }.join(", ")
		end

		# def request(method, url, body, headers = {})
  # 			hash = if method == :post
  #   		{
  #     			"Accept" => "*/*",
  #     			"Content-Type" => "application/x-www-form-urlencoded"
  #   		}
  # 			else
  #   			{}
  # 			end

  # 			Excon.send(method, url, :body => body, :headers => hash.merge(headers)) # Hit that server yo.
		# end

		# def api_call(url, method = :get, data = "")
  #  			authentication, params = generate_authentication_hash({ :oauth_token => @access_token }), { :alt => "jsonc" }
  #  			authentication.merge! oauth_signature(secret_string(@secret, Tumblr.find_by_user_id(5).oauth_secret), method, url, authentication, params)
 
  #  			headers = {
  #    			"Authorization" => authorization_string(authentication),
  #    			"GData-Version" => "2", # http://code.google.com/apis/calendar/data/2.0/developers_guide_protocol.html#Versioning
  #    			"Accept" => "application/json"
  #  			}
  #  			headers["Content-Type"] = "application/json" if method == :post
 
  #  			request(method, url + "?" + normalize_parameters(params), data, headers)
 	# 	end
end