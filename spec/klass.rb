class Klass

  def lit_and_hash lit = 2, hash = {:a => 1, :b => 2}
    [one, two, three]
  end
  
  def with_call call = Klass.new
    [one, two, three, yield]
  end
  
  def with_call_and_args call = Klass.new(1,2,3)
    [one, two, three, yield]
  end
  
  def asr attackTime = 3, sustainLevel = 2, releaseTime = 1, curve = 0
    [attackTime, sustainLevel, releaseTime, curve]
  end
  
  def no_args
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