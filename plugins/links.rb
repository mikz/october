gem 'redis-objects'

class Links
  autoload :Link, 'links/link'

  include October::Plugin

  prefix /^!links?(?:\s+)?/
  match /add\s+(\S+)(?:\s+)?(.+)?$/, method: :add
  match /list/, method: :list
  match '', method: :list

  def add m, url, desc = nil
    link = Link.create url, scope(m), description: desc, user: m.user.nick
    m.reply 'Link added'
  end

  def list m
    links = Link.list scope(m)
    m.reply links.map(&:to_list).join("\n")
  end

  private
  def scope(message)
    message.channel or message.user.nick or raise 'no scope'
  end
end
