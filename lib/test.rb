require 'iseq_parser'
require 'ruby_parser'
require 'pp'

module Kernel 
def ppb
end
end

def parse iseq
  IseqParser.new(iseq).parse
end

def rb_parse string
  RubyParser.new.parse string
end

def compile string
  RubyVM::InstructionSequence.compile( string ).to_a
end


pp compile <<-RUBY_EVAL
def hola(a = 1, b = 2); c = 1; end
RUBY_EVAL