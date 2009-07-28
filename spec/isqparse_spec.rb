require "#{ dir = File.dirname(__FILE__) }/../lib/iseq_parser"
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
      parse( [[:putstring, "string"]] ).should  == rb_parse('"string"')
    end
  end
  
  shared_examples_for 'expression' do
    it "should parse exp" do
      parse( compile("1#{ @op }2") ).should == rb_parse("1#{ @op }2")
    end
    
    it "should parse recursive op" do
      parse( compile("1#{ @op }2#{ @op }3") ).should == rb_parse("1#{ @op }2#{ @op }3")
    end
    
    it "should really parse recursive op" do
      parse( compile("1#{ @op }2#{ @op }3#{ @op }4") ).should == rb_parse("1#{ @op }2#{ @op }3")
    end
  end
  
  describe 'sum' do
    before do
      @op = '+'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'mult' do
    before do
      @op = '*'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'minus' do
    before do
      @op = '-'
    end
    it_should_behave_like 'expression'
  end
  
  describe 'div' do
    before do
      @op = '/'
    end
    it_should_behave_like 'expression'
  end
  
  describe '**' do
    before do
      @op = '**'
    end
    it_should_behave_like 'expression'
  end
  
end