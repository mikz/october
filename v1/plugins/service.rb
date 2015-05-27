class Service
  include October::Plugin
  register_help 'guys [msg]', 'focuses all users in channel'

   match /guys(\W+.+?)?$/, method: :guys

   def guys(m, msg)
     users = m.channel.users.keys.reject{|u| u == bot }
     m.reply [users.join(', '), msg].compact.join(':')
   end
end
