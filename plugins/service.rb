class Service
  include October::Plugin
  register_help 'guys', 'focuses all users in channel'

   match 'guys', method: :guys

   def guys m
     users = m.channel.users.keys
     m.reply users.join(', ')
   end
end
