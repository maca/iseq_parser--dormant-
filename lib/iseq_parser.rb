require 'sexp_processor'

class IseqParser
  V      = /[^\s]+/
  VS     = /#{ V }(?=\n)/
  PLA    = /(?=\()/
  SPLA   = /(?=\s+#{ PLA })/
  VSPLA  = /#{ V }#{ SPLA }/
  MVSPLA = /(?:#{ V },\s)+#{ V }/
  
  def initialize
    @tree, @partial, @stack = s(), s(), s()
  end
  
  def argument_names iseq
    iseq.to_s.scan /(#{ V })<(Arg|Opt|Rest)/
  end

  #   def parse_iseq iseq
  #     array  = []
  #     iseq.scan /(?:\d{4}\s)(\w+)(?:\s+)(#{VS}|#{VPLA}|#{MVPLA}|#{PLA})/ do |pair|
  #       case pair.first
  #       when "trace", "leave", "getinlinecache", "setinlinecache"
  #       else
  #         pair.push *pair.pop.scan V
  #         array << pair
  #       end
  #     end
  #     array
  #   end
  
  def parse exp
    sexp = process exp
    # p sexp
    return sexp.pop || s(:nil) if sexp.size <= 1
    sexp.unshift(:block)
  end
  
  OPERATORS = { 'opt_mult' => :*, 'opt_plus' => :+, "opt_minus" => :-, "opt_div" => :/ }
  
  def process exp, acc = s()
    val  = exp.pop
    inst = val.shift
    # p ">>#{inst}-#{val}"
    
    sexp =
    case inst = inst.to_s
    when 'putobject', 'putstring'
      case val = val.first
      when Numeric, Symbol
        s(:lit, val)
      when true, false
        s(val.to_s.to_sym)
      when String
        s(:str, val)
      end
    
    when 'duparray'
      s(:array, *val.collect{ |v| s(:lit, v)  })
    
    when 'newhash', 'newarray'
      size = val.pop
      sexp = process exp, acc = s()
      sexp.push *@stack
      
      elements = []
      while elements.size < size
        elements << sexp.pop
      end
      
      s( inst.sub('new', '').to_sym, *elements )
      
    when /opt_\w+/
      sexp = process exp
      s(:call, sexp.pop, OPERATORS[inst], s(:arglist, sexp.pop))
    
    when 'send'
      method, argcount = val.shift, val.shift
      sexp, args       = process(exp), []
      
      while args.size < argcount
        args.unshift sexp.shift
      end
      
      caller   = sexp.shift || @partial.shift
      @partial = sexp unless sexp.empty?
      s(:call, caller, method, s(:arglist, *args))
    
    when 'trace'
    
    when 'putnil'
      # p @stack
      # p acc
      # p process(exp)
      process(exp, @stack)
      # p exp
      nil
        
    when 'leave', 'pop'
      return process(exp, @stack)
      
    else  
      raise "Instruction #{ inst.inspect } not valid"
      
    end
    
    acc.push sexp    if     sexp
    process exp, acc unless exp.empty?
    acc
  end
end


