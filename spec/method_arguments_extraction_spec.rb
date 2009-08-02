require "#{ dir = File.dirname __FILE__ }/spec_helper"
require "#{ dir }/klass"

describe 'arguments names and corresponding values extraction' do
  it "should get argument names for lit and hash with lits" do
    method = method_iseq Klass.instance_method(:lit_and_hash)
    IseqParser.argument_names( method ).should == [["lit", "Opt"], ["hash", "Opt"]]
  end

  it "lit and hash with lits" do
    method = method_iseq Klass.instance_method(:lit_and_hash)
    IseqParser.argument_values( method ).should == [["lit", s(:lit, 2)], ["hash", s(:hash, s(:lit, :a), s(:lit, 1), s(:lit, :b), s(:lit, 2))]]
  end
  
  it "call with no args" do
    method = method_iseq Klass.instance_method(:with_call)
    IseqParser.argument_values( method ).should == [["call", s(:call, s(:const, :Klass), :new, s(:arglist))]]
  end
  
  
  it "call with literal args" do
    method = method_iseq Klass.instance_method(:with_call_and_args)
    IseqParser.argument_values( method ).should == [["call", s(:call, s(:const, :Klass), :new, s(:arglist, s(:lit, 1), s(:lit, 2), s(:lit, 3)))]]
  end
  
  it "with_hash_and_calls" do
    method = method_iseq Klass.instance_method(:with_hash_and_calls)
    p IseqParser.iseq_from_string method
    IseqParser.argument_values( method ).should == [["hash", rb_parse('{:a => Klass.new(1,2), :b => 2, :c => [[5]]}')]]
  end
  

end