require './Parsers/firebase-parser.rb'
require './Clients/firebase-client.rb'

include FirebaseParser
include FirebaseClient

module FirebaseHandler
  def query_searches(params)
    puts "searching firebase.."
    slack_data = FirebaseParser.parse_slack_response_for_google_query params[:slack_data]
    response = FirebaseClient.query_firebase slack_data[:user], params[:firebase_data]
  end

  def log_google_search(params)
    puts "Logging to firebase.."
    params[:firebase_data][:params] = GoogleParser.parse_slack_response_for_google_search params[:slack_data]
    response = FirebaseClient.post_google_search params[:firebase_data]
    puts response.code
  end

  def log_twitter_search(params)
    puts "Logging to firebase.."
    params[:firebase_data][:params] = GoogleParser.parse_slack_response_for_google_search params[:slack_data]
    response = FirebaseClient.post_twitter_search params[:firebase_data]
    puts "Response: " + response.code.to_s
  end

  def log_tweet(params)
    puts "Logging to firebase.."
    params[:firebase_data][:params] = TwitterParser.parse_slack_response_for_tweet params[:slack_data]
    response = FirebaseClient.post_tweet params[:firebase_data]
    puts "Response: " + response.code.to_s
  end
end
