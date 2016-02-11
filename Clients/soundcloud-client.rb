module SoundcloudClient
  sc_yaml = YAML.load_file("./settings.yml")
  @client = Soundcloud.new(:client_id => sc_yaml["soundcloud"]["client_id"])

  def get_tracks slack_data
    tracks = @client.get('/tracks', :q => slack_data[:search_term], :licence => 'cc-by-sa')
    tracks.first  
  end
end
