require 'yaml'
require 'byebug'
require 'slack-ruby-client'
require './clients.rb'
require './helpers.rb'
require './handlers.rb'

include Clients
include Helpers
include Handlers

yaml = YAML.load_file("settings.yml")
Slack.configure do |config|
  config.token = yaml['token']
end

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
  when /hi kitt/i
    puts data
    @client.message channel: data.channel, text: ":fu:"

  when /kitt~google/i
    @client.message channel: data.channel, text: "let me grab that real quick.."
    google_parser = Parsers::Google.new()
    @params[:slack_data] = google_parser.parse_slack_response_for_google_search(data)
    @params[:firebase_data] = {endpoint: "google_question", params: @params[:slack_data]}
    firebase = Handlers::Firebase.new(@params)
    firebase.log_google_search
    google = Handlers::Google.new(@params[:slack_data][:text])
    result = google.get_result()
    @client.message channel: data.channel, text:  "Title: " + result.title
    @client.message channel: data.channel, text:  "Link: " + result.link
    #Handlers::Google && Handlers::Firebase
  when /kitt~searchTwtter/i
    @client.message channel: data.channel, text: "let me grab that real quick.."
    google_parser = Parsers::Google.new()
    @params[:slack_data] = google_parser.parse_slack_response_for_google_search(data)
    @params[:firebase_data] = {endpoint: "google_question", params: @params[:slack_data]}
    firebase = Handlers::Firebase.new(@params)
    firebase.log_google_search
    google = Handlers::Google.new(@params[:slack_data][:text])
    result = google.get_result()
    @client.message channel: data.channel, text:  "Title: " + result.title
    @client.message channel: data.channel, text:  "Link: " + result.link
    #Handlers::Google && Handlers::Firebase
  when /kitt~backSearch/i
    @client.message channel: data.channel, text: "searching.."
    firebase_parser = Parsers::Firebase.new()
    @params[:slack_data] = firebase_parser.parse_slack_response_for_google_query(data)
    @params[:firebase_data] = {endpoint: "google_question", params: @params[:slack_data]}
    firebase = Handlers::Firebase.new(@params[:firebase_data])
    response = firebase.query_searches
    if response.empty?
      @client.message channel: data.channel, text: "No results"
    else
      response.each do |search_term|
        @client.message channel: data.channel, text: "`#{search_term}`"
      end
    end
    #Handlers::Firebase
  when /kitt~help/i
    @client.web_client.reactions_add name: 'awyeah', timestamp: data.ts, channel: data.channel
  end
  when /awyeah/i
    @client.web_client.reactions_add name: 'awyeah', timestamp: data.ts, channel: data.channel
  end
end

@client.start!
