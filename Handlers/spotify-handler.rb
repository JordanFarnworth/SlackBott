require './Parsers/spotify-parser.rb'
require './Clients/spotify-client.rb'

include SpotifyParser
include SpotifyClient

module SpotifyHandler

  def search_spotify params
    slack_data = SpotifyParser.parse_slack_response_for_spotify_request params[:slack_data]
    results = SpotifyClient.send_search_to_spotify slack_data
  end

end
