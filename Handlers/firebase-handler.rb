require './Parsers/firebase-parser.rb'
require './Clients/firebase-client.rb'
require './Parsers/spotify-parser.rb'

include FirebaseParser
include SpotifyParser
include FirebaseClient

module FirebaseHandler
  def query_searches(params)
    puts "searching firebase.."
    slack_data = FirebaseParser.parse_slack_response_for_google_query params[:slack_data]
    response = FirebaseClient.query_firebase slack_data[:user], params[:firebase_data]
  end

  def log_spotify_response_to_firebase params
    puts "Logging #{params[:firebase_data][:endpoint]} to firebase.."
    params[:firebase_data][:params] = SpotifyParser.parse_slack_response_for_spotify_request params[:slack_data]
    response = FirebaseClient.post_firebase_data params[:firebase_data]
    puts response.code
  end

  def log_google_search(params)
    puts "Logging #{params[:firebase_data][:endpoint]} to firebase.."
    params[:firebase_data][:params] = GoogleParser.parse_slack_response_for_google_search params[:slack_data]
    response = FirebaseClient.post_firebase_data params[:firebase_data]
    puts response.code
  end

  def log_twitter_search(params)
    puts "Logging #{params[:firebase_data][:endpoint]} to firebase.."
    params[:firebase_data][:params] = GoogleParser.parse_slack_response_for_google_search params[:slack_data]
    response = FirebaseClient.post_firebase_data params[:firebase_data]
    puts "Response: " + response.code.to_s
  end

  def log_tweet(params)
    puts "Logging #{params[:firebase_data][:endpoint]} to firebase.."
    params[:firebase_data][:params] = TwitterParser.parse_slack_response_for_tweet params[:slack_data]
    response = FirebaseClient.post_firebase_data params[:firebase_data]
    puts "Response: " + response.code.to_s
  end
end
