class TwitterController < ApplicationController
  before_filter :authenticate_user!

  def generate_twitter_oauth_url
    # oauth_callback = "https://sandbox-rails-craigthusiast.c9users.io/oauth_account"  #This was in the tutorial, but it doesn't work.
  	@callback_url = "https://sandbox-rails-craigthusiast.c9users.io/oauth/callback"
  
  	@consumer = OAuth::Consumer.new("JVc8WRvkZwjLc3RNRFR8M40Xk","lje5gyYpBgEZRJ398PdY6eF3eN61oAzCF738RNTq1s56IyaXo6", :site => "https://api.twitter.com")
  
    # @request_token = @consumer.get_request_token(:oauth_callback => oauth_callback)  #This was in the tutorial, but it doesn't work.
    @request_token = @consumer.get_request_token(:oauth_callback => @callback_url)
  	session[:request_token] = @request_token
  
    # redirect_to @request_token.authorize_url(:oauth_callback => oauth_callback)  #This was in the tutorial, but it doesn't work.
  	redirect_to @request_token.authorize_url(:oauth_callback => @callback_url)
  	
  end
  
  def oauth_account
  	if TwitterOauthSetting.find_by_user_id(current_user.id).nil?
  		@request_token = session[:request_token]
  		@access_token = @request_token.get_access_token(:oauth_verifier => params["oauth_verifier"])
  		TwitterOauthSetting.create(atoken: @access_token.token, asecret: @access_token.secret, user_id: current_user.id)
  		update_user_account()
  	end
  	redirect_to "/twitter_profile"
  end
  
  def get_client
  	Twitter.configure do |config|
  	  config.consumer_key = "JVc8WRvkZwjLc3RNRFR8M40Xk"
  	  config.consumer_secret = "lje5gyYpBgEZRJ398PdY6eF3eN61oAzCF738RNTq1s56IyaXo6"
  	end
  
  	Twitter::Client.new(
  	  :oauth_token => TwitterOauthSetting.find_by_user_id(current_user.id).atoken,
  	  :oauth_token_secret => TwitterOauthSetting.find_by_user_id(current_user.id).asecret
  	)
  end
  
  def index
  	unless TwitterOauthSetting.find_by_user_id(current_user.id).nil?
  	redirect_to "/twitter_profile" end
  end
  
  def twitter_profile
    @user_timeline = get_client.user_timeline
    @home_timeline = get_client.home_timeline
  end
  
  def update_user_account
    user_twitter_profile = get_client.user_twitter_profile
    current_user.update_attributes({
      name: user_twitter_profile.name,
      screen_name: user_twitter_profile.screen_name,
      url: user_twitter_profile.url,
      profile_image_url: user_twitter_profile.profile_image_url,
      location: user_twitter_profile.location,
      description: user_twitter_profile.description })
  end
  
  def timeline
    @tweets = Client.user_timeline[0..4] # For this demonstration lets keep the tweets limited to the first 5 available.
    # @tweets = Client.user_timeline.first("craigthusiast") # For this demonstration lets keep the tweets limited to the first 5 available.
  end

end
