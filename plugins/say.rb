class Say
  include October::Plugin

  match /say (.+)$/, method: :say

  register_help 'say', 'say stuff as october.'
  def say(m, text)
    m.reply text
  end
end
