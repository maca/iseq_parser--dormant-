require 'iseq_parser'
require 'ruby_parser'

module Kernel 
def ppb
end
end

def parse iseq
  IseqParser.new.parse iseq
end

def rb_parse string
  RubyParser.new.parse string
end

def compile string
  RubyVM::InstructionSequence.compile( string ).to_a.last.reject{ |e| not Array === e  }
end

a = parse( compile('[a, [b, 1]]') )
b = rb_parse('[a, [b, 1]]')

exp = "1 ** 2 ** 3"
parse( compile(exp) ).should == rb_parse(exp)
