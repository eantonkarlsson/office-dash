require 'twitter'


#### Get your twitter keys & secrets:
#### https://dev.twitter.com/docs/auth/tokens-devtwittercom
twitter = Twitter::REST::Client.new do |config|
  config.consumer_key = '5TmkfvxK6SvsLVVPyAxCFvm3T'
  config.consumer_secret = 'TMIDE6gFhXMHmj8vL4yW2TuEz7ZMihDWuxJb9SRNZjBoRzX7Ry'
  config.access_token = '	887316246743666688-BLxGxhTQJ3KDilWn2HvZ3iuWW92E51Y'
  config.access_token_secret = 'umb5pxE4WCtG2HP6V5y8vhuUVITWdxO5QZHM3CKvMRBVF'
end

SCHEDULER.every '15m', :first_in => 0 do |job|
  begin
    user = twitter.user
    if mentions
      mentions = mentions.map do |tweet|
        { name: tweet.user.name, body: tweet.text, avatar: tweet.user.profile_image_url_https }
      end

    send_event('twitter_mentions', {comments: mentions})
    end    
  rescue Twitter::Error
    puts "\e[33mThere was an error with Twitter\e[0m"
  end

end
