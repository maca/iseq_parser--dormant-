require "#{ dir = File.dirname __FILE__ }/../lib/iseq_parser"
require 'ruby_parser'

module Kernel
  def ppb obj
    return obj.join('<br/>') if Array === obj
    puts obj.to_s.gsub("\n", '<br/>')
  end
end

def parse iseq
  IseqParser.new(iseq).parse
end

def rb_parse string
  RubyParser.new.parse string
end

def compile string
  iseq = RubyVM::InstructionSequence.compile( string ).to_a
end

def method_iseq method
  RubyVM::InstructionSequence.disassemble method
end