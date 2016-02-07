require 'yaml'
require 'byebug'
require 'slack-ruby-client'
require 'twitter'
require 'net/http'
require 'json'
require 'firebase'
require 'rspotify'
require './Handlers/twitter-handler.rb'
require './Handlers/firebase-handler.rb'
require './Handlers/google-handler.rb'
require './Handlers/spotify-handler.rb'

include TwitterHandler
include FirebaseHandler
include GoogleHandler
include SpotifyHandler

yaml = YAML.load_file("settings.yml")
Slack.configure do |config|
  config.token = yaml['slack']['token']
end
GOOGLE_API_KEY = yaml['google']['api_key']
GOOGLE_SEARCH_CX = yaml['google']['search_engine']

@client = Slack::RealTime::Client.new

@params = {
  firebase_data: {},
  slack_data: {}
}

@client.on :hello do
  puts "Connected #{@client.self.name} to #{@client.team.name}"
end

@client.on :message do |data|
  case data.text
  when /:fu:/
    puts data
    @client.message channel: data.channel, text: ":fu:"

  when /kitt~google/i
    @params[:slack_data] = data
    @params[:firebase_data] = {endpoint: "google_question", params: {}}
    FirebaseHandler.log_google_search @params
    result = GoogleHandler.get_result @params
    begin
      @client.message channel: data.channel, text:  "Title: " + result.title
      @client.message channel: data.channel, text:  "Link: " + result.link
    rescue
      @client.message channel: data.channel, text:  "Error with google handler. Check your API keys/search engine id if this is a mistake"
    end

  when /kitt~searchTwitter/i
    @params[:slack_data] = data
    @params[:firebase_data] = {endpoint: "twitter_search", params: {}}
    FirebaseHandler.log_twitter_search @params
    result = TwitterHandler.search_twitter @params
    unless result.nil?
      if result[:type] == "user_search"
        @client.message channel: data.channel, text: "Link: " + result[:user].uri.to_s
        @client.message channel: data.channel, text: result[:user].profile_image_url_https.to_s
      elsif result[:type] == "tweet_search"
        result[:matches].each do |tweet|
          @client.message channel: data.channel, text: "*User:* " + tweet.user.screen_name.to_s
          @client.message channel: data.channel, text: "*Tweet:* " + tweet.text.to_s
          @client.message channel: data.channel, text: "*Link:* " + tweet.uri.to_s
        end
      elsif result[:type] == "user_tweet_search"
        @client.message channel: data.channel, text: "*Link:* " + result[:match].uri.to_s
        @client.message channel: data.channel, text: "*Tweet:* " + result[:match].text.to_s
      elsif result[:type] == "error"
        @client.message channel: data.channel, text: result[:error].to_s
      else
        @client.message channel: data.channel, text: "twitter-client return error"
      end
    else
      @client.message channel: data.channel, text: "Search came back empty"
    end

  when /kitt~tweet/i
    @params[:slack_data] = data
    @params[:firebase_data] = {endpoint: "tweet", params: {}}
    FirebaseHandler.log_tweet @params
    tweet = TwitterHandler.tweet @params
    unless tweet.class == Array
      @client.message channel: data.channel, text: "tweet sent"
      @client.message channel: data.channel, text: tweet.uri.to_s
    else
      @client.message channel: data.channel, text: "text can't be blank"
    end

  when /kitt~backSearch/i
    @params[:slack_data] = data
    @params[:firebase_data] = {endpoint: "google_question", params: {}}
    response = FirebaseHandler.query_searches @params
    if response.empty?
      @client.message channel: data.channel, text: "No results"
    else
      response.each do |search_term|
        @client.message channel: data.channel, text: "`#{search_term}`"
      end
    end

  when /%spotify/i
    @params[:slack_data] = data
    @params[:firebase_data] = {endpoint: "spotify", params: {}}
    FirebaseHandler.log_spotify_response_to_firebase @params
    response = SpotifyHandler.search_spotify @params
    @client.message channel: data.channel, text: response[:result].uri.to_s

  when /%help/i
    @client.message channel: data.channel, text: "*phrase-to-summon-kitt*  <phrase that kitt needs to opperate> (don't includes the <>'s in your search ex: `kitt~google your mom`)"
    @client.message channel: data.channel, text: "*kitt~google*  <your google phrase>"
    @client.message channel: data.channel, text: "*kitt~backSearch*  #<User> (must have capitolized first letter of name)"
    @client.message channel: data.channel, text: "*^^^* will show you all the google searches a user has performed"
    @client.message channel: data.channel, text: "*kitt~tweet*  <your tweet for kitt bot>"
    @client.message channel: data.channel, text: "*kitt~searchTwitter*   #U<username> -optional if search term is present <your search term> -optional if username is present "
    @client.message channel: data.channel, text: "*%spotify*  -s <song title>, -a <album title>, -ar <artist name>, -p <playlist title>"
    @client.message channel: data.channel, text: "*_ note for %spotify_*  only takes one param at a time, so you can't do %spotify -s one love, -a justin bieber."
    @client.message channel: data.channel, text: "*_ note for %spotify_*  instead, just search for the artist, and find the song that way. ex: %spotify -a justin bieber"


  when /awyeah/i
    @client.web_client.reactions_add name: 'awyeah', timestamp: data.ts, channel: data.channel
  end

end

@client.start!
