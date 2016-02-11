require './helpers.rb'

include Helpers

module SoundcloudParser

  def parse_slack_response_for_soundcloud slack_data
    text = slack_data.text
    search_term = Helpers.shift_param text
    return {search_term: search_term}
  end

end
