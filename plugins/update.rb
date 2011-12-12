class Update
  include October::Plugin

  match /selfupdate$/, method: :selfupdate
  match /seppuku$/, method: :seppuku

  def selfupdate(m)
    m.reply "starting selfupdate..."
    `git fetch origin`
    `git reset --hard origin/master`
    m.reply "selfupdate completed!"
  end

  def seppuku(m)
    m.reply("bye... AGRG!! ahh...")
    sleep(1)
    exit(0)
  end
end
