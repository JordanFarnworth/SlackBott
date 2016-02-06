require 'firebase'

 module Clients
  class FireBase
    # example of what config would look like
    def initialize(config, base_uri = 'https://kittbot.firebaseio.com/')
      @firebase = Firebase::Client.new(base_uri)
      @config = config
      @users = Helpers.users
    end

    def log_google_search
      @firebase.push(@config[:endpoint], @config[:params])
    end

    def query_firebase(term)
      responses = @firebase.get(@config[:endpoint])
      matches = []
      items = responses.body.to_a
      items.each do |item|
        item.each do |object|
          if object.class == Hash && object["user"] == term
            matches << object["text"]
          else
            next
          end
        end
      end
      matches
    end

  end
 end
