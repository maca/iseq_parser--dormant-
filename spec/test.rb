require "#{ dir = File.dirname __FILE__ }/../lib/iseq_parser"
require "#{ dir }/klass"

def method_iseq method
  RubyVM::InstructionSequence.disassemble method
end

two = method_iseq Klass.instance_method(:two)

puts two