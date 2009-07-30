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
    p exp
    
    sexp = process exp
    
    sexp || s(:nil)
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
      sexp = process exp
      s( inst.sub('new', '').to_sym, *sexp.shift(size).reverse )
      
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
      # parse exp
      
    when 'pop'
      # til = exp.rindex( [:putnil] ) || 0
      # process( exp.pop(exp.size - til), a = s() ).first
      
    when 'leave'
      return process(exp).first
      
    else  
      raise "#{ inst } not valid"
      
    end
    
    acc.push sexp    if     sexp
    process exp, acc unless exp.empty?
    
    acc
  end
end


