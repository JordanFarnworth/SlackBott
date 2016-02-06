require 'google_custom_search_api'

require './clients.rb'
require './helpers.rb'
require './parsers.rb'

include Clients
include Helpers
include Parsers

GOOGLE_API_KEY = "AIzaSyD89RZDbTxB33o9t3_9OIW1YUu0iwKO6xI"
GOOGLE_SEARCH_CX = "016908783022293081179:iu-_dcaxot8"


module Handlers
  class Google

    def initialize(term)
      @results = GoogleCustomSearchApi.search(term)
    end


    def get_result
      if @results != Array && @results["error"]
        error = results["error"]["errors"][0]["message"]
        hash = { "error" => error }
      else
        @results.items[0]
      end
    end

  end

  class Firebase

    def initialize(params)
      @params = params
    end

    def query_searches
      puts "searching firebase.."
      firebase_client = Clients::FireBase.new(@params)
      response = firebase_client.query_firebase @params[:params][:user]
    end

    def log_google_search
      puts "Logging to firebase.."
      firebase_client = Clients::FireBase.new(@params[:firebase_data])
      response = firebase_client.log_google_search
      puts response.code
    end
  end

  class Twitter

  end
end
