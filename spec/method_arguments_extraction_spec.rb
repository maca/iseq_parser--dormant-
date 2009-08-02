require "#{ dir = File.dirname __FILE__ }/spec_helper"
require "#{ dir }/klass"

describe 'arguments names and corresponding values extraction' do
  it "should get argument names for lit and hash with lits" do
    method = method_iseq Klass.instance_method(:lit_and_hash)
    IseqParser.argument_names( method ).should == [["lit", "Opt"], ["hash", "Opt"]]
  end

  it "should arguments names and for values lit and hash with lits" do
    method = method_iseq Klass.instance_method(:lit_and_hash)
    IseqParser.argument_values( method ).should == [["lit", s(:lit, 2)], ["hash", s(:hash, s(:lit, :a), s(:lit, 1), s(:lit, :b), s(:lit, 2))]]
  end
  
  it "should arguments names and call with no args" do
    method = method_iseq Klass.instance_method(:with_call)
    IseqParser.argument_values( method ).should == [["call", s(:call, s(:const, :Klass), :new, s(:arglist))]]
  end
  
  it "should arguments names and call with no args" do
    method = method_iseq Klass.instance_method(:with_call_and_args)
    IseqParser.argument_values( method ).should == [["call", s(:call, s(:const, :Klass), :new, s(:arglist, s(:lit, 1), s(:lit, 2), s(:lit, 3)))]]
  end
end