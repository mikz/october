class SonosPlugin
  include October::Plugin

  self.prefix = /^!sonos /
  %w[status playing play next pause stop].each do |operation|
    match operation, method: operation.to_sym
  end

  match /volume(?:\s+(\+|\-)?(\d+))?/, method: :volume

  register_help 'status', 'what is current status'
  register_help 'playing', 'what is currently playing'
  register_help 'play', 'play music'
  register_help 'next', 'next song'
  register_help 'pause', 'pause music'
  register_help 'stop', 'stop music'
  register_help 'volume', 'control volume (+10, -10, 10, nada)'

  def initialize(*)
    super
    @system = Sonos::System.new
  end

  def status(m)
    state = master.get_player_state
    m.reply "#{state.fetch(:status)} state:#{state.fetch(:state)}"
  end

  def play(m)
    master.play
    m.reply 'sonos should be playing'
  end

  def next(m)
    master.next
    m.reply 'next song playing'
  end

  def pause(m)
    master.pause
    m.reply 'sonos paused'
  end

  def stop(m)
    master.stop
    m.reply 'sonos stopped'
  end

  def playing(m)
    unless master.has_music?
      return m.reply 'nothing'
    end

    song = master.now_playing

    msg = '%s by %s from %s (%s/%s)' %
        song.values_at(:title, :artist, :album, :current_position, :track_duration)

    m.reply msg
  end

  def volume(m, sign, amount)
    case sign
      when '-'
        master.volume -= amount.to_i
        m.reply "volume #{sign}#{amount}"
      when '+'
        master.volume += amount.to_i
        m.reply "volume #{sign}#{amount}"
      else
        if amount.nil? || amount.empty?
          m.reply "the volume is: #{master.volume}"
        else
          master.volume = amount.to_i
          m.reply "volume set to #{amount}"
        end
    end
  end
  private

  def master
    @system.find_party_master
  end
end
