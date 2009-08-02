require 'sexp_processor'

class IseqParser
  attr_reader :locals, :arguments, :iseq
  V      = /[^\s]+/
  VS     = /#{ V }(?=\n)/
  PLA    = /(?=\()/
  SPLA   = /(?=\s+#{ PLA })/
  VSPLA  = /#{ V }#{ SPLA }/
  MVSPLA = /(?:#{ V },\s)+#{ V }/
  
  class << self
    def argument_names iseq
      iseq.to_s.scan /(#{ V })<(Arg|Opt|Rest)/
    end

    def iseq_from_string iseq
      iseq.scan( /(?:\d{4}\s)(\w+)(?:\s+)(#{ VS }|#{ VSPLA }|#{ MVSPLA }|#{ PLA })/ ).collect do |pair|
        values = pair.pop.scan( /(?:\w|:|\d)+/ ).collect do |value|
          val  = 
          case value
          when /:[^\s]+/  then value.gsub(':', '').to_sym
          when /\d+/      then value.to_i
          when 'nil'      then nil
          when 'true'     then true
          else value end 
        end
        pair.push *values
      end
    end
  
    def argument_values iseq
      iseq_array = iseq_from_string iseq
      argument_names( iseq ).collect do |pair|
        name, type = pair
        consumed   = []
        next pair unless type == 'Opt'
        until (ins = iseq_array.shift) == ['setlocal', name ]
          consumed.push ins
        end
        pair[1] = new([consumed.push(['leave'])]).parse
        pair
      end
    end
  end
  
  def initialize iseq
    # p iseq
    @context   = iseq[7]
    @locals    = iseq[8]
    @arguments = iseq[9]
    @sexp      = s()
    @labels    = {}
    rejected   = [:getinlinecache, :setinlinecache, :dup]
    @iseq      = iseq.last.reject do |i| 
      next true unless Array === i
      rejected.include?( i.first.to_sym )
    end
    # p @iseq
  end
  
  def parse
    sexp = process @iseq
    return sexp unless sexp.first == :block
    sexp.compact!
    return sexp.pop if sexp.size == 2
    sexp
  end
  
  # opt_neg
  OPERATORS = { 'opt_mult' => :*, 'opt_plus' => :+, "opt_minus" => :-, "opt_div" => :/, "opt_mod" => :%,  
                "opt_eq" => :==, 'opt_le' => :<=, 'opt_gt' => :>, 'opt_ge' => :>=, 'opt_ltlt' => :<<,
                'opt_aref' => :[], 'opt_aset' => :[]=, 'opt_length' => :size }
  GETS      = { 'getconstant' => :const, 'getlocal' => :lvar, 'getinstancevariable' => :ivar, 'getclassvariable' => :cvar }
  SETS      = { 'setlocal' => :lasgn, 'setinstancevariable' => :iasgn, 'setclassvariable' => :cvdecl }
  
  def process exp, acc = s(), remaining = s()
    return acc if exp.empty?
      values  = exp.pop
    if Array === values
      inst    = values.shift
    else
      inst    = values
    end
    
    
    consumed  =
    case inst = inst.to_s
      
    # when /label/
    #   @label = inst
    #   process(exp).pop
    #   # p "the sexp #{sexp}"
    #   # 
    #   # if @labels.delete( inst ) == 'branchunless'
    #   #   s(:and, @sexp.pop, remaining.shift)
    #   # else
    #   #   sexp.pop
    #   # end
      
    when 'putobject', 'putstring'
      case value = values.first
      when Numeric, Symbol
        s(:lit, value)
      when true, false
        s(value.to_s.to_sym)
      when String  
        s(:str, value)
      end

    when *GETS.keys
      name = values.pop
      name = @locals[name * -1 + 1] if inst == 'getlocal'
      s(GETS[inst], name)
      
    when *SETS.keys
      name      = values.first
      name      = @locals[name * -1 + 1] if inst == 'setlocal'
      remaining = process exp
      result    = s(SETS[inst], name, remaining.shift || @sexp.pop)
      @sexp << result 
      nil

    when 'duparray'
      s(:array, *values.collect{|v| s(:lit, v)} )
      
    when 'opt_not'
      s(inst.to_s.gsub('opt_', '').to_sym, *process(exp))
      
    when /opt_\w+/
      remaining = process exp
      s(:call, remaining.pop, OPERATORS[inst], s(:arglist, remaining.pop))
    
    when 'send'
      method, argcount = values.shift, values.shift
      remaining, args  = process(exp), []
      
      if method == :'core#define_method'
        remaining[0][1][1] if @optionals  # !!!
        name   = remaining.pop
        block  = remaining.pop
        s(:defn, name.last, s(:args, *@defargs), block)
      else
        args.unshift remaining.shift || @sexp.pop while args.size < argcount
        receiver = remaining.shift
        s(:call, receiver, method, s(:arglist, *args))
      end
      
    when 'newhash', 'newarray'
      size, elements = values.pop, []
      remaining      = process exp
      elements.unshift remaining.shift || @sexp.pop while elements.size < size
      s( inst.sub('new', '').to_sym, *elements )

    # when 'dup'
    #   return process exp

    when 'branchunless'
      @labels[values.pop.to_s] = inst
      return process(exp)

    when 'putnil'
      nil
      
    when 'getinlinecache'
      return process exp

    when 'setinlinecache'
      return process exp
                
    when 'pop'
      sexp = process exp
      sexp = [sexp] if Symbol === sexp.first
      @sexp.push *sexp
      nil
    
    when 'leave'
      @sexp.push *process( exp, acc )
      result = @sexp.dup and @sexp.clear
      return result.pop || s(:nil) unless result.size > 1
      result.unshift :block unless Symbol === result.first
      return result
      
    when 'trace'
      return process exp
      
    when 'defineclass'
      remaining    = process exp
      name         = values.shift
      instructions = values.shift
      body         = self.class.new(instructions).parse
      scope        = s(:scope)
      scope.push body unless body == s(:nil)
      s(:class, name, remaining.pop, scope)
      
    when 'putiseq'
      parser    = self.class.new *values
      sexp      = parser.parse
      argcount  =
      if Fixnum === parser.arguments
        parser.arguments
      else
        @optionals = true
        parser.arguments[1].size - 1
      end
      @defargs  = parser.locals[0...argcount]
      s(:scope, s(:block, sexp))
      
    when 'putspecialobject'
      return process exp
      
    # when /\d+/
    #   return process exp
      
    else
      # return process exp
      raise "Instruction #{ inst.inspect } not valid"
    end
    
    acc.push consumed
    acc.push *remaining  unless remaining.empty?
    process  exp,  acc   unless exp.empty?
    acc
  end
end