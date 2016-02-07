require './Parsers/twitter-parser.rb'
require './Clients/twitter-client.rb'

include TwitterParser
include TwitterClient

module TwitterHandler

  def search_twitter(params)
    twitter_data = TwitterParser.twitter_parse_slack_response_for_twitter_search params[:slack_data]
    response = TwitterClient.search twitter_data
  end

  def tweet(params)
    twitter_data = TwitterParser.parse_slack_response_for_tweet params[:slack_data]
    response = TwitterClient.send_tweet twitter_data
  end

end
