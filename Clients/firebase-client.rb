@users = Helpers.users

module FirebaseClient
  @firebase = Firebase::Client.new('https://kittbot.firebaseio.com/')

  def post_firebase_data firebase_data
    @firebase.push(firebase_data[:endpoint], firebase_data[:params])
  end

  def query_firebase(term, firebase_data)
    responses = @firebase.get(firebase_data[:endpoint])
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
