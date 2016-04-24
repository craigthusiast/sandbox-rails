class TweetsController < ApplicationController
  
  def index
    # @tweets = Twitter.user_timeline[0..4]("craigthusiast") # For this demonstration lets keep the tweets limited to the first 5 available.
    @tweets = Twitter.user_timeline.first("craigthusiast") # For this demonstration lets keep the tweets limited to the first 5 available.
  end

end
