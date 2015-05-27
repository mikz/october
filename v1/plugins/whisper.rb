class Whisper
  include October::Plugin

  self.react_on = :private

  self.prefix = ''

  match /!whisper (.+)$/, method: :whisper
  match /(.+)$/, method: :queue

  listen_to :part, method: :close
  listen_to :join, method: :flush

  register_help 'whisper name', 'starts "whisper" mode, all messages will be sent to user when joins'

  ACTIVE = Hash.new{ |hash, key| hash[key] = {} }
  OPENED = {}

  def whisper(m, nick)
    synchronize(:whisper) do
      ACTIVE[nick][m.user.nick] = [Time.now.to_s]
      OPENED[m.user.nick] = nick
      m.reply "Whisper mode started"
    end
  end

  def queue(m, text)
    return unless opened?(m.user)

    synchronize(:whisper) do
      nick  = m.user.nick
      opened = OPENED[nick]
      return if text == "!whisper #{opened}"

      ACTIVE[opened][nick] << text
      m.reply "Message enqueued"
    end
  end

  def close(m)
    return unless opened?(m.user)

    synchronize(:whisper) do
      OPENED.delete(m.user.nick)
    end
  end

  def flush(m)
    user = m.user
    return unless ACTIVE.has_key?(user.nick)

    synchronize(:whisper) do
      queue = ACTIVE[m.user.nick]
      queue.keys.each do |sender|
        messages = queue.delete(sender)
        user.msg "You have #{messages.size - 1} messages from #{sender}:"

        while line = messages.shift
          user.msg line
        end
      end
    end
  end

  private
  def opened?(user)
    return unless user
    OPENED.has_key?(user.nick)
  end
end
