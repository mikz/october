gem 'redis-objects'

class Links
  autoload :Link, 'links/link'

  include October::Plugin

  self.prefix = /^!links?(?:\s+)?/

  match /add\s+(\S+)(?:\s+)?(.+)?$/, method: :add
  match /rem(?:ove)?\s+(\d+)$/, method: :remove
  match /list/, method: :list
  match '', method: :list

  register_help 'link[s] add uri [description]', 'add uri to database with optional description'
  register_help 'link[s] [list]', 'list all saved links in this scope (channel of nick)'
  register_help 'link[s] rem[ove] id', 'remove specific link'

  def add m, url, desc = nil
    link = Link.create url, scope(m), description: desc, user: m.user.nick
    m.reply 'Link added'
  end

  def remove m, id
    link = Link.find(id, scope(m))
    if link and link.remove
      m.reply "Link #{id} removed"
    else
      m.reply "Link #{id} not found"
    end
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
