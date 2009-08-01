require 'sexp_processor'

class IseqParser
  V      = /[^\s]+/
  VS     = /#{ V }(?=\n)/
  PLA    = /(?=\()/
  SPLA   = /(?=\s+#{ PLA })/
  VSPLA  = /#{ V }#{ SPLA }/
  MVSPLA = /(?:#{ V },\s)+#{ V }/
  
  def initialize
    @tree, @partial, @stack, @sexp = s(), s(), s(), s()
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
    p exp
    sexp = process exp
  end
  
  OPERATORS = { 'opt_mult' => :*, 'opt_plus' => :+, "opt_minus" => :-, "opt_div" => :/ }
  
  def process exp, acc = s()
    val  = exp.pop
    inst = val.shift
    
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
      
    when 'setlocal'
      sexp = process(exp)
      s(:lasgn, :a, *sexp)
    
    when 'duparray'
      s(:array, *val.collect{|v| s(:lit, v)} )
      
    when /opt_\w+/
      sexp = process exp
      s(:call, sexp.pop, OPERATORS[inst], s(:arglist, sexp.pop))
    
    when 'send'
      method, argcount = val.shift, val.shift
      sexp, args       = process(exp), []
      
      while args.size < argcount
        args.unshift sexp.shift
      end
      caller = sexp.shift
      
      acc.push s(:call, caller, method, s(:arglist, *args))
      acc.push *sexp
      return acc
      
    when 'newhash', 'newarray'
      size     = val.pop
      sexp     = process exp
      elements = []
      
      while elements.size < size
        elements.unshift sexp.shift
      end
      
      acc.push s( inst.sub('new', '').to_sym, *elements )
      acc.push *sexp
      return acc
      

    when 'dup'
      return process exp
      
    when 'putnil'
      # process exp, acc
      nil
        
    when 'leave', 'pop'
      sexp = process exp, acc
      sexp = sexp.pop unless Symbol === sexp.first
      
      @sexp.push sexp
      return @sexp.unshift(:block) if @sexp.size > 1
      return sexp || s(:nil)
    
    when 'trace'
      return acc
      
    else  
      raise "Instruction #{ inst.inspect } not valid"
      
    end
    
    acc.push sexp
    process  exp,  acc unless exp.empty?
    acc
  end
end


