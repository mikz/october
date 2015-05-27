gem 'json'

require 'httpclient/include_client'

class Joke
  extend HTTPClient::IncludeClient
  include_http_client

  include October::Plugin
  API_URL = "http://api.icndb.com/jokes/random?firstName=<first_name>&lastName=<last_name>"

  match /joke(?: (\S+)(?: (\S+))?)?$/, method: :joke

  register_help 'joke [first_name] [last_name]', 'Tells you a joke. Chuck Norris style!'
  def joke(m, first_name = nil, last_name = nil)
    first_name ||= m.user.nick

    joke = request(first_name, last_name)
    m.reply joke["value"]["joke"]
  end


  private

  def request(first_name, last_name)
    url = API_URL.dup
    url.sub! "<first_name>", first_name.to_s
    url.sub! "<last_name>", last_name.to_s

    response = self.class.http_client.get(url)

    JSON.parse(response.body)
  end

end
