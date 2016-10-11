require 'date'

class TestSuite
  attr_reader :name, :timestamp
  attr_accessor :test_cases
  
  def initialize(name)
    @name = name
    @test_cases = []
    @timestamp = DateTime.now
  end
  
  def failures
    @test_cases.count { |test| test.failed? }
  end
  
  def time
    @test_cases.map { |test| test.time }.inject(:+)
  end
end

class TestCase
  attr_reader :name
  attr_accessor :messages
  
  def initialize(name)
    @name = name
    @messages = []
    @failed = true
    @start = Time.now
    @finish = nil
  end
  
  def <<(message)
    @messages << message
  end
  
  def pass!
    @failed = false;
    @finish = Time.now
  end
  
  def fail!
    @finish = Time.now
  end
  
  def failed?
    @failed
  end
  
  def time
    return 0 if @finish.nil?
    @finish - @start
  end
end

# Creates a XML report that conforms to # https://svn.jenkins-ci.org/trunk/hudson/dtkit/dtkit-format/dtkit-junit-model/src/main/resources/com/thalesgroup/dtkit/junit/model/xsd/junit-4.xsd
class XunitOutput
  def initialize(filename)
    @filename = filename
    @suite = TestSuite.new(File.basename(filename, File.extname(filename)))
  end
  
  def add(line)
    return if @suite.test_cases.empty?
    @suite.test_cases.last << line
  end
  
  def add_status(status, date, time, time_zone, msg)
    case status
    when :start
      @suite.test_cases << TestCase.new(msg)
    when :pass
      @suite.test_cases.last.pass! if @suite.test_cases.last != nil
    when :fail
      @suite.test_cases.last.fail! if @suite.test_cases.last != nil
    else
      if @suite.test_cases.last != nil && @suite.test_cases.last.time == 0
        @suite.test_cases.last << "#{status.to_s.capitalize}: #{msg}"
      end
    end
  end
  
  def close
    File.open(@filename, 'w') { |f| f.write(serialize(@suite)) }
  end
  
  def xml_escape(input)
     result = input.dup

     result.gsub!("&", "&amp;")
     result.gsub!("<", "&lt;")
     result.gsub!(">", "&gt;")
     result.gsub!("'", "&apos;")
     result.gsub!("\"", "&quot;")

     return result
  end
  
  def serialize(suite)
    output = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" << "\n"
    output << "<testsuite name=\"#{xml_escape(suite.name)}\" timestamp=\"#{suite.timestamp}\" time=\"#{suite.time}\" tests=\"#{suite.test_cases.count}\" failures=\"#{suite.failures}\">" << "\n"
    
    suite.test_cases.each do |test|
      output << "  <testcase name=\"#{xml_escape(test.name)}\" time=\"#{test.time}\">" << "\n"
      if test.failed?
        output << "    <failure>#{test.messages.map { |m| xml_escape(m) }.join("\n")}</failure>" << "\n"
      end
      output << "  </testcase>" << "\n"
    end

    output << "</testsuite>" << "\n"
  end
end