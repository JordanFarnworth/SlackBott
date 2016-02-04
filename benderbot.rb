require 'yaml'
require 'byebug'
require 'slack-ruby-client'

yaml = YAML.load_file("settings.yml")
Slack.configure do |config|
  config.token = yaml['token']
end

@client = Slack::RealTime::Client.new

@client.on :hello do
  puts "Connected #{@client.self.name} to #{@client.team.name}"
end

@client.on :message do |data|
  case data.text
  when /hi bender/i
    @client.message channel: data.channel, text: "Bite my shiny metal ass!"
  when /aw yeah/i
    @client.web_client.reactions_add name: 'awyeah', timestamp: data.ts, channel: data.channel
  end
end

@client.start!
