module TwitterClient

  yaml_again = YAML.load_file("./settings.yml")
  @twitter_client = Twitter::REST::Client.new do |config|
    config.consumer_key        = yaml_again['twitter']['consumer_key']
    config.consumer_secret     = yaml_again['twitter']['consumer_secret']
    config.access_token        = yaml_again['twitter']['access_token']
    config.access_token_secret = yaml_again['twitter']['access_token_secret']
  end


  def send_tweet(twitter_data)
    begin
      response = @twitter_client.update(twitter_data[:tweet])
      response
    rescue
      return []
    end
  end

  def search(data)

    yaml = YAML.load_file("./settings.yml")
    matches = []
    unless data.nil?
      if data[:twitter_user] == ""
        st = data[:search_term]
        begin
          @twitter_client.search("#{st} -rt").take(2).collect do |tweet|
            matches << tweet
          end
        rescue
          return {type: "error", error: yaml['twitter']['error_message']}
        end
        matches = {type: "tweet_search", matches: matches}
      elsif data[:search_term] == ""
        begin
          user = @twitter_client.user("#{data[:twitter_user]}")
        rescue
          return {type: "error", error: yaml['twitter']['error_message']}
        end
        user = {type: "user_search", user: user}
      elsif data[:twitter_user] != "" && data[:search_term] != ""
        begin
          @twitter_client.search("from:#{data[:twitter_user]} #{data[:search_term]}").take(1).collect do |tweet|
            matches << tweet
          end
        rescue
          return {type: "error", error: yaml['twitter']['error_message']}
        end
        unless matches.empty?
          matches = {type: "user_tweet_search", match: matches.pop}
        else
          return {type: "error", error: yaml['twitter']['error_message']}
        end
      else
        return {type: "error", error: "Malformatted request. Search can't be blank"}
      end
    else
      return {type: "error", error: "Search can't be blank"}
    end
  end

end
