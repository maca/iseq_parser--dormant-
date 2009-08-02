require "#{ dir = File.dirname __FILE__ }/spec_helper"

describe IseqParser do
  
  it "should parse pass trace" do
    lambda { parse( [[[:spurious], [:trace, 4], [:leave]]] ) }.should raise_error
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
      parse( [[[:putstring, "string"], [:leave]]] ).should  == rb_parse('"string"')
    end
    
    it "should parse lits" do
      parse( compile('true') ).should  == rb_parse('true')
      parse( compile('false') ).should == rb_parse('false')
    end
    
    it "should put nil" do
      parse( compile('nil') ).should == rb_parse('nil')
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
    
    it "should parse Constant" do
      exp = 'Object'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse dup Array" do
      # method `inspect' called on terminated object if compiling
      parse( [[[:duparray, 1, 2, 3, 4], [:leave]]] ).should == rb_parse('[1,2,3,4]')
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
    
    it "should parse recursive call" do
      parse( compile("a.b(1)") ).should == rb_parse("a.b(1)")
    end
    
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
    
    it "should parse method call with args" do
      exp = 'a(1, 2)'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse method call with args and receiver" do
       exp = 'Klass.new(1, 2, 3)'
       parse( compile(exp) ).should == rb_parse(exp)
     end
    
    it "should parse nested method calls" do
      exp = 'a(b(1, 2))'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse nested method calls 2" do
      exp = 'a(b(c(d(), 3), 2), 1)'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse recursive op" do
      parse( compile("1#{ @op }2#{ @op2 }3") ).should == rb_parse("1#{ @op }2#{ @op2 }3")
    end
  end
  
  describe 'Stack' do
    it "should parse several expressions" do
      exp = 'a; 1+2; Ob'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse several expressions 2" do
      exp = 'a; b(1);'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse several expressions returning lit" do
      exp = 'a; 1'
      parse( compile(exp) ).should == rb_parse(exp)
    end
    
    it "should parse Array with call with args" do
      parse( compile('[a(1)]') ).should == rb_parse('[a(1)]')
    end
    
    it "should parse Array with literal and call with args" do
      parse( compile('[1, a(2, 3)]') ).should == rb_parse('[1, a(2, 3)]')
    end
    
    it "should parse Hash with calls" do
      parse( compile('{:a => 1, :b => 2, :c => c}') ).should  == rb_parse('{:a => 1, :b => 2, :c => c}')
    end

    it "should parse not empty Array" do
      parse( compile('[1, :a, a]') ).should  == rb_parse('[1, :a, a]')
    end
    
    it "should parse nested Array" do
      parse( compile('[a, [b, 1]]') ).should  == rb_parse('[a, [b, 1]]')
    end
    
    it "should parse nested Array 2" do
      parse( compile('[a, [b, [c, 1]]]') ).should  == rb_parse('[a, [b, [c, 1]]]')
    end
    
    it "should parse nested Array 3" do
      exp = '[[b, c], [d, e]]'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse nested Array 2" do
      exp = '[[b, c], a, [d, e]]'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse method call with array" do
      parse( compile('a([])') ).should == rb_parse('a([])')
    end
    
    it "should parse method call with array" do
      parse( compile('a([b()])') ).should == rb_parse('a([b()])')
    end
    
    it "should parse method call with array" do
      parse( compile('a([1, 2, b()])') ).should == rb_parse('a([1, 2, b()])')
    end
    
    it "should parse {:a => Klass.new(1,2), :b => 2}" do
      exp = '{:a => Klass.new(1,2), :b => 2}'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse {:a => Klass.new(1,2), :b => 2, :c => [[5]]}" do
      exp = '{:a => Klass.new(1,2), :b => 2, :c => [[]]}'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
  end
  
  describe 'Assign' do
    it "should parse lassign" do
      exp = 'a = 1'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse lassign with call" do
      exp = 'a = a(1)'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse lassign with array" do
      exp = 'a = [1, b(2, 2)]'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse instance variable set" do
      exp = '@var = 1'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse lassign 2" do
      exp = 'a = 1; b = 2; c = 3'
      parse( compile(exp) ).should  == rb_parse(exp)
    end

    it "should assign and literal" do
      exp = 'a = 1; :a'
      parse( compile(exp) ).should == rb_parse(exp)
    end

    it "should parse assign and get" do
      exp = 'a = b(); a'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse call and assign" do
      exp = 'a( b = 1 )'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse call and assign 2" do
      exp = 'a( b = 1, c = 2 )'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse concat assign" do
      exp = 'a = b = 2'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse array and assing" do
      exp = '[a = 1, b = 2]'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse instance variable get" do
      exp = '@var = 1; @var'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse class variable set" do
      exp = '@@var = 1; @@var'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
    
    it "should parse class variable get" do
      exp = '@@var'
      parse( compile(exp) ).should  == rb_parse(exp)
    end
  end

end