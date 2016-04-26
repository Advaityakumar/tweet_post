class PostsController < ApplicationController
  
  require 'oauth'

  def index
  end
  
  def post_tweet
    # Fetch access token
    consumer, access_token = prepare_access_token
    req = consumer.create_signed_request(:post, "/1.1/statuses/update.json", access_token, {}, :status => params[:message])
    auth_header = req.as_json['authorization'].first
    
    begin
      # Post tweet to twitter with th access token on the belave of user
      response = RestClient.post("https://api.twitter.com/1.1/statuses/update.json",  {status: params[:message]},
                {:accept_encoding => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3", :accept => "*/*",
                 :user_agent => "OAuth gem v0.5.1", :content_length => "0",
                 :content_type => "application/x-www-form-urlencoded" ,
                 :Authorization => auth_header})
      flash[:notice] = "Tweet posted successfully"
    rescue Exception => e
      # Catching errors
    	body = JSON.parse e.http_body.as_json
      errors = []
      body['errors'].each do |error|
        errors << error['message']
      end
      flash[:error] = errors.join(",")
    end
    redirect_to root_url
  end
  
  def prepare_access_token
    consumer = OAuth::Consumer.new(ENV['CONSUMER_KEY'], ENV['CONSUMER_SECRET'], { :site => "https://api.twitter.com", :scheme => :header })
     
    # now create the access token object from passed values
    token_hash = { :oauth_token => ENV['ACCESS_TOKEN'], :oauth_token_secret => ENV['ACCESS_SECRET_KEY'] }
    access_token = OAuth::AccessToken.from_hash(consumer, token_hash )
 
    return consumer, access_token
  end
end

