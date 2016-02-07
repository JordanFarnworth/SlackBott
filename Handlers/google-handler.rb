require './Parsers/google-parser.rb'
require "google_custom_search_api"

include GoogleParser

module GoogleHandler

  def get_result(data)
    slack_data = GoogleParser.parse_slack_response_for_google_search(data[:slack_data])
    results = get_google_result slack_data[:text]
    if results != Array && results["error"]
      error = results["error"]["errors"][0]["message"]
      hash = { "error" => error }
    else
      results.items[0]
    end
  end

  def get_google_result(text)
    results = GoogleCustomSearchApi.search text
  end
end
