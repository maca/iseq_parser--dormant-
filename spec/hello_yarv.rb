
class HelloYARV
  def self.say
    self.new.say
  end

  def say
    puts 'Hello YARV: Yet Another RubyVM!'
  end

  def file_and_line
    p __FILE__
    p __LINE__
  end

  def if_else
    if true
      p true
    else
      p false
    end
  end

  def while_sample
    while true
      p :while
      break
    end
  end

  def exception_sample
    begin
      raise
    rescue E1
      p :E1
    rescue E2
      p :E2
    else
      p :else
    ensure
      p :ensure
    end
  end
end

