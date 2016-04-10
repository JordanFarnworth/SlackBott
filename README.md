A slack bot with some API integrations

integrates with:

Google Search Bar
Spotify
SoundCloud
Jira
Twitter

add creds to your settings.yml file and everything should just work. I will add links for creating these creds at the bottom of this doc

cd app_root_level
ruby bot.rb

you might get a conflicting gem package warning, this is expected. Create a gemset that does now require only one version of the gem. I have tested pretty well, and this doesn't break anything.

the basic flow is like so:

slack messages comes into server
bot runs the command through a regex matcher thx to the slack api gem I am using <3
bot matches the regex, and usually will match that command to a handler
the handler then separates concerns by having a parser parse the options
those options are then passed to the client by the handlers
the client comes back to the handler with a response
the handler passes that information to the bot.rb file
slack bot response with the information from the handler

that's it, pretty simple.

that being said, you will need quite a few creds

slack:

  token: https://api.slack.com/web


google:

  api_key: https://developers.google.com/maps/documentation/javascript/get-api-key

  search_engine: https://support.google.com/customsearch/answer/2630963?hl=en


twitter:

  consumer_key: https://apps.twitter.com/

  consumer_secret: https://apps.twitter.com/

  access_token: https://apps.twitter.com/

  access_token_secret: https://apps.twitter.com/

  error_message: just put an error message here. twitters api throws dumb exceptions

  (the error message I use: no results found. if you think this is a mistake, check your access keys and tokens)

spotify:

  client_id: https://developer.spotify.com/web-api/

  client_secret: https://developer.spotify.com/web-api/

soundcloud:

  client_id: https://github.com/soundcloud/soundcloud-ruby

jira:

  username: https://docs.atlassian.com/jira/REST/latest/

  password: https://docs.atlassian.com/jira/REST/latest/@@

  url: https://docs.atlassian.com/jira/REST/latest/
  
  (good luck ^)
