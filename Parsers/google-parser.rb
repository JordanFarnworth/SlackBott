require './helpers.rb'

include Helpers

module GoogleParser
  @users = Helpers.users

  def parse_slack_response_for_google_search(data)
    user = @users[data.user.to_sym]
    text = data.text.split(" ")
    text.shift
    text = text.join(" ")
    hash = {text: text, user: user}
  end
end
