require './Clients/soundcloud-client.rb'
require './Parsers/soundcloud-parser.rb'

include SoundcloudClient
include SoundcloudParser
module SoundcloudHandler
  def search_soundcloud params
    slack_data = SoundcloudParser.parse_slack_response_for_soundcloud params[:slack_data]
    track = SoundcloudClient.get_tracks slack_data
  end
end
