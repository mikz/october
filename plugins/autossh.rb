class Autossh
  include October::Plugin

  match /tunnels?$/, method: :reconnect

  register_help 'tunnel[s]', 'Reconnects autossh tunnels'

  def reconnect(m)
    pids = IO.popen('ps ux | grep "auto[s]sh"') do |io|
      io.readlines.map { |line|
        line.split(/\s+/)[1].to_i
      }
    end

    m.reply "Found #{pids.count} autossh processes"

    unless pids.empty?
      m.reply "Sending SIGUSR1 to pid: #{pids.join(", ")}"
      Process.kill('USR1', *pids)
    end
  end

end
