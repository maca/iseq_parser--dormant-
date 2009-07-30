require "#{ dir = File.dirname __FILE__ }/../lib/iseq_parser"
require 'ruby_parser'
require "#{ dir }/klass"
require 'pp'

describe IseqParser do
  
  def parse iseq
    IseqParser.new.parse iseq
  end
  
  def rb_parse string
    RubyParser.new.parse string
  end
  
  def compile string
    RubyVM::InstructionSequence.compile( string ).to_a.last.reject{ |e| not Array === e  }
  end
  
  describe 'Literal parsing' do
    it "should parse numeric" do
      parse( compile('1') ).should   == rb_parse('1')
      parse( compile('1.1') ).should == rb_parse('1.1')
    end
    
    it "should parse symbol" do
      parse( compile(':a') ).should  == rb_parse(':a')
    end
    
    it "should parse string" do
      # method `inspect' called on terminated object if compiling
      parse( [[:putstring, "string"], [:leave]] ).should  == rb_parse('"string"')
    end
    
    it "should parse lits" do
      parse( compile('true') ).should  == rb_parse('true')
      parse( compile('false') ).should == rb_parse('false')
    end
    
    it "should put nil" do
      parse( compile('nil') ).should   == rb_parse('nil')
    end
    
    it "should parse emtpy Hash" do
      parse( compile('{}') ).should  == rb_parse('{}')
    end
    
    it "should parse Hash with literals" do
      parse( compile('{:a => 1, :b => 2}') ).should  == rb_parse('{:a => 1, :b => 2}')
    end
    
    it "should parse empty Array" do
      parse( compile('[]') ).should  == rb_parse('[]')
    end
    
    it "should parse dup Array" do
      # method `inspect' called on terminated object if compiling
      parse( [[:duparray, 1, 2, 3, 4], [:leave]] ).should == rb_parse('[1,2,3,4]')
    end
  end
  
  shared_examples_for 'expression' do
    it "should parse exp" do
      parse( compile("1#{ @op }2") ).should == rb_parse("1#{ @op }2")
    end
    
    it "should parse recursive op" do
      parse( compile("1#{ @op }2#{ @op2 }3") ).should == rb_parse("1#{ @op }2#{ @op2 }3")
    end
    
    it "should really parse recursive op" do
      parse( compile("1#{ @op }2#{ @op2 }3#{ @op3 }4") ).should == rb_parse("1#{ @op }2#{ @op2 }3#{ @op3 }4")
    end
    
    it "should really really parse recursive op" do
      parse( compile("1#{ @op }2#{ @op2 }3#{ @op3 }4#{ @op4 }5") ).should == rb_parse("1#{ @op }2#{ @op2 }3#{ @op3 }4#{ @op4 }5")
    end
  end
  
  describe 'sum' do
    before do
      @op = @op2 = @op3 = @op4 = '+'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'mult' do
    before do
      @op = @op2 = @op3 = @op4 = '*'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'sub' do
    before do
      @op = @op2 = @op3 = @op4 = '-'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'div' do
    before do
      @op = @op2 = @op3 = @op4 = '/'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'method calls' do
    before do
      @op = @op2 = @op3 = @op4 = '**'
    end
    it_should_behave_like 'expression'
    
    it "should parse a single method call with no args" do
      parse( compile('a') ).should == rb_parse('a')
    end
    
    it "should parse a single method call with args" do
      parse( compile('a(:one, :two)') ).should == rb_parse('a(:one, :two)')
    end
    
    it "should parse chained method calls with args" do
      exp = 'a(:one, :two).b(:one, :two).c(:one, :two)'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse nested method calls" do
      exp = 'a(b(c(d(), 3), 2), 1)'
      parse( compile(exp) ).should == rb_parse(exp)
    end
  end
  
  describe 'Stack' do
    it "should several expressions" do
      parse( compile('a; b(1);') ).should == rb_parse('a; b; c; d')
    end
    
    it "should parse Hash with calls" do
      parse( compile('{:a => 1, :b => 2, :c => c}') ).should  == rb_parse('{:a => 1, :b => 2, :c => c}')
    end
    
    it "should parse not empty Array" do
      parse( compile('[1, :a, a]') ).should  == rb_parse('[1, :a, a]')
    end
  end
  
end