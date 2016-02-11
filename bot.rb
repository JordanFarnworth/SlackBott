require 'yaml'
require 'byebug'
require 'slack-ruby-client'
require 'twitter'
require 'net/http'
require 'json'
require 'firebase'
require 'rspotify'
require 'soundcloud'
require './Handlers/twitter-handler.rb'
require './Handlers/google-handler.rb'
require './Handlers/spotify-handler.rb'
require './Handlers/soundcloud-handler.rb'
require './helpers.rb'

include TwitterHandler
include GoogleHandler
include SpotifyHandler
include SoundcloudHandler
include Helpers

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

  when /%google/i
    @params[:slack_data] = data
    # FirebaseHandler.log_google_search @params
    result = GoogleHandler.get_result @params
    begin
      @client.message channel: data.channel, text:  "Title: " + result.title
      @client.message channel: data.channel, text:  "Link: " + result.link
    rescue
      @client.message channel: data.channel, text:  "Error with google handler. Check your API keys/search engine id if this is a mistake"
    end

  when /%twitter/i
    @params[:slack_data] = data
    result = TwitterHandler.search_twitter @params
    unless result.nil?
      if result[:type] == "user_search"
        @client.message channel: data.channel, text: "Link: " + result[:user].uri.to_s
      elsif result[:type] == "tweet_search"
        result[:matches].each do |tweet|
          @client.message channel: data.channel, text: "*Link:* " + tweet.uri.to_s
        end
      elsif result[:type] == "user_tweet_search"
        @client.message channel: data.channel, text: "*Link:* " + result[:match].uri.to_s
      elsif result[:type] == "error"
        @client.message channel: data.channel, text: result[:error].to_s
      else
        @client.message channel: data.channel, text: "twitter-client return error"
      end
    else
      @client.message channel: data.channel, text: "Search came back empty"
    end

  when /%tweet/i
    @params[:slack_data] = data
    tweet = TwitterHandler.tweet @params
    unless tweet.class == Array
      @client.message channel: data.channel, text: "tweet sent"
      @client.message channel: data.channel, text: tweet.uri.to_s
    else
      @client.message channel: data.channel, text: "text can't be blank"
    end

  when /%spotify/i
    @params[:slack_data] = data
    response = SpotifyHandler.search_spotify @params
    if response[:result]
      @client.message channel: data.channel, text: response[:result].uri.to_s
    else
      @client.message channel: data.channel, text: "***** search value can't be blank."
      @client.message channel: data.channel, text: "***** type *-s* to search songs, *-a* for albums, *-ar* for artists, and *-p* for playlists."
      @client.message channel: data.channel, text: "***** only one search value is allowed per search."
    end

  when /%soundcloud/i
    @params[:slack_data] = data
    response = SoundcloudHandler.search_soundcloud @params
    @client.message channel: data.channel, text: response.permalink_url.to_s


  when /%help/i
    @client.message channel: data.channel, text: "*%<weebo_command>*  <parameters and search phrases> (don't includes the <>'s in your search ex: `%google your mom`)"
    @client.message channel: data.channel, text: "*%google*  <your google phrase>"
    @client.message channel: data.channel, text: "*%soundcloud*  <your soundcloud search term>"
    @client.message channel: data.channel, text: "*%tweet*  <your tweet for kitt bot>"
    @client.message channel: data.channel, text: "*%twitter*   *-u* <username> (_optional if search term is present, but username must be listed first if you want to search a user for a specific tweet_) <your search term> (_optional if username is present_)"
    @client.message channel: data.channel, text: "*%spotify*  -s <song title>, -a <album title>, -ar <artist name>, -p <playlist title>"
    @client.message channel: data.channel, text: "*[note for ^^^]*  this command only takes one param at a time, so you can't do *%spotify* *-s* one love, *-a* justin bieber."


  when /awyeah/i
    @client.web_client.reactions_add name: 'awyeah', timestamp: data.ts, channel: data.channel
  end
end
@client.start!
