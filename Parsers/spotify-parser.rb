require './helpers.rb'

include Helpers

module SpotifyParser

  @users = Helpers.users

  def parse_slack_response_for_spotify_request data
    #text example: %spotify -s I took a pill
    user = @users[data.user.to_sym]
    a = data.text.split(" ")
    a.shift
    string = a.join(" ")
    find_match string, user
  end

  def find_match string, user
    looper = {}
    looper[:song] = string.match /(\B-s)/
    looper[:playlist] = string.match /(\B-p)/
    looper[:album] = string.match /(\B-a)/
    looper[:artist] = string.match /(\B-ar)/
    get_match looper, string, user
  end

  def get_match looper, string, user
    search_term = Helpers.shift_param string
    user = user
    type = ""
    looper.each do |k, v|
      unless looper[k].nil?
        type = find_type looper[k][0]
      else
        next
      end
    end
    if type.class == String
      hash = { search_term: search_term, type: type, user: user }
    else
      return {type: "error", error: "Can only search one param at a time, or your params didn't match the help guide format"}
    end
  end


  def find_type param_type
    type = ""
    json = {song: '-s' , playlist: '-p', album: '-a', artist: '-ar'}
    json.each do |k, v|
      if json[k] == param_type
        type = k.to_s
      end
    end
    type
  end

end
