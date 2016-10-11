class AbbreviatedConsoleOutput < ColoredConsoleOutput

  def add_status(status, date, time, time_zone, msg)
    message = format(status, msg)
    if !message.nil?
      puts message
    end
  end

  def format(status, msg)
    output = nil
    if status
        output = self.message_for_status(status, msg);
        output = colorize(output, STATUS_COLORS[status]) if STATUS_COLORS[status]
    end
    output
  end

  def message_for_status(status, msg)
    message = nil
    case status
      when /^default/
        message = "    > #{msg}"
      when /^start/
        message = "\n> #{status.to_s.capitalize}: #{msg}"
      when /^fail/
        message = "X #{status.to_s.capitalize}: #{msg}"
      when /^pass/
        message = "#{status.to_s.capitalize}: #{msg}"
      when /^warning/
        message = "    ! #{status.to_s.capitalize}: #{msg}"
      when /^issue/
        message = "    ! #{status.to_s.capitalize}: #{msg}"
    end

    message
  end
end
