gem 'typhoeus'

class Fortune
  include October::Plugin

  match /fortune?$/, method: :fortune

  register_help 'fortune', 'fortune YO!'
  def fortune(m)
    response = Typhoeus::Request.get "http://www.fortunefortoday.com/getfortuneonly.php"
    m.reply response.body.strip
  end
end
