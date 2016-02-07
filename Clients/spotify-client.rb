module SpotifyClient
  yaml_spotify = YAML.load_file("./settings.yml")
  RSpotify.authenticate(yaml_spotify['spotify']['client_id'], yaml_spotify['spotify']['client_secret'])

  def send_search_to_spotify slack_data
    if slack_data[:type] == 'artist'
      search_spotify_for_artist slack_data[:search_term]
    elsif slack_data[:type] == 'album'
      search_spotify_for_album slack_data[:search_term]
    elsif slack_data[:type] == 'playlist'
      search_spotify_for_playlist slack_data[:search_term]
    elsif slack_data[:type] == 'song'
      search_spotify_for_song slack_data[:search_term]
    else
      return {type: "error", error: "client type error"}
    end
  end

  def search_spotify_for_artist search_term
    artists = RSpotify::Artist.search(search_term)
    return {type: "artist", result: artists.first}
  end

  def search_spotify_for_album search_term
    albums = RSpotify::Album.search(search_term)
    return {type: "artist", result: albums.first}
  end

  def search_spotify_for_song search_term
    songs = RSpotify::Track.search(search_term)
    return {type: "song", result: songs.first}
  end

  def search_spotify_for_playlist search_term
    playlists = RSpotify::Playlist.search(search_term)
    return {type: "playlist", result: playlists.first}
  end

end
