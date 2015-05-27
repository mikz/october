class Help
  include October::Plugin
  register_help 'help', 'list all registered commands with description'

   match 'help', method: :help

   def help(m)
     m.user.msg 'October help:'
     m.user.msg self.class.list_help
   end
end
