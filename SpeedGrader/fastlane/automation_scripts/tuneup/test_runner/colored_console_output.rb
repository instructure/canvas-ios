class ColoredConsoleOutput < ConsoleOutput
  COLORS = {
    :red => 31,
    :green => 32,
    :yellow => 33,
    :cyan => 36
  }
  
  STATUS_COLORS = {
    :start => :cyan,
    :pass => :green,
    :fail => :red,
    :error => :red,
    :warning => :yellow,
    :issue => :yellow
  }
  
  def format(status, date, time, time_zone, msg)
    output = super
    output = colorize(output, STATUS_COLORS[status]) if STATUS_COLORS[status]
    output
  end
  
  def colorize(text, color)
    "\e[#{COLORS[color]}m#{text}\e[0m"
  end
end