require './helpers.rb'

include Helpers

module FirebaseParser
  @users = Helpers.users

  def parse_slack_response_for_google_query(data)
    requestor = @users[data.user.to_sym]
    user = data.text.match(/\B#(\w\w+)/)
    user = user[1]
    {requestor: requestor, user: user}
  end


    def firebase_parse_slack_response_for_twitter_search(data)
      user = @users[data.user.to_sym]
      twitter_user = data.text.match(/\B#U:(\w\w+)/)
      if twitter_user
        twitter_user = twitter_user[1]
      else
        twitter_user = ""
      end
      search_term = data.text
      search_term = search_term.split(" ")
      unless twitter_user == ""
        search_term.shift && search_term.shift
      else
        search_term.shift
      end
      search_term = search_term.join(" ")
      return {twitter_user: twitter_user, search_term: search_term, user: user}
    end

end
