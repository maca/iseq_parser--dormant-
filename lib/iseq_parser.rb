require 'sexp_processor'

class IseqParser
  V      = /[^\s]+/
  VS     = /#{ V }(?=\n)/
  PLA    = /(?=\()/
  SPLA   = /(?=\s+#{ PLA })/
  VSPLA  = /#{ V }#{ SPLA }/
  MVSPLA = /(?:#{ V },\s)+#{ V }/
  
  def initialize
    @tree, @partial = s(), s()
  end
  
  # def argument_names
  #     iseq.scan /(#{ V })<(Arg|Opt|Rest)/
  #   end
  #       
  #   def parse_iseq iseq
  #     array  = []
  #     iseq.scan /(?:\d{4}\s)(\w+)(?:\s+)(#{vs}|#{vspla}|#{mvspla}|#{pla})/ do |pair|
  #       case pair.first
  #       when "trace", "leave", "getinlinecache", "setinlinecache"
  #       else
  #         pair.push *pair.pop.scan(/[^\s,]+/)
  #         array << pair
  #       end
  #     end
  #     array
  #   end
  
  def parse exp
    if (sexp = process(exp.compact).compact).size == 1
      sexp.first
    else
      sexp
    end
  end
  
  OPERATORS = { 'opt_mult' => :*, 'opt_plus' => :+, "opt_minus" => :-, "opt_div" => :/ }
  
  def process exp, acc = []
    return @tree if exp.empty?
    
    p '------------'
    # pp exp
    val = exp.pop
    inst = val.shift
    
    p ">>#{inst}"
    
    sexp =
    case inst = inst.to_s
      
    when 'putobject', 'putstring'
      case val = val.first
      when Numeric, Symbol
         s(:lit, val)
      when String
         s(:str, val)
      end
      
    when /opt_\w+/
      vals = process exp
      s(:call, vals.pop, OPERATORS[inst], s(:arglist, vals.pop))
    
    when 'send'
      method, argcount = val.shift, val.shift 
      vals    = process exp
      caller  = vals.pop
      arglist = s(:arglist, *vals[0...argcount])
      @tree.shift
      s(:call, caller, method, arglist)
      # s(:call, )
      # s(:call)
    
    
    when 'leave', 'trace'
    else  
      raise "#{ inst } not valid"
    end
    
    @tree.push sexp.compact if sexp
    process exp
    @tree
  end
  
  

end


