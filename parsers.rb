require './helpers.rb'

include Helpers

module Parsers
  class Twitter

    def initialize
      @users = Helpers.users
    end

    def parse_slack_response_for_twitter_search(data)
      requestor = @users[data.user.to_sym]
    end
  end
  class Firebase

    def initialize
      @users = Helpers.users
    end

    def parse_slack_response_for_google_query(data)
      requestor = @users[data.user.to_sym]
      user = data.text.match(/\B#(\w\w+)/)
      user = user[1]
      {requestor: requestor, user: user}
    end
  end

  class Google

    def initialize
      @users = Helpers.users
    end

    def parse_slack_response_for_google_search(data)
      user = @users[data.user.to_sym]
      text = data.text.split(" ")
      text.shift
      text = text.join(" ")
      hash = {text: text, user: user}
    end

  end
end
