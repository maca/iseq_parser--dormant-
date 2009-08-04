require "#{ dir = File.dirname __FILE__ }/spec_helper"

describe 'Logic' do
  it "should parse not" do
    exp = 'not true'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse true if true" do
    parse( compile('true if true') ).should  == rb_parse("true")
  end

  it "should parse and with literals" do
    exp = 'true and false'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse and" do
    exp = 'a and b'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse or" do
    exp = 'a or b'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse && and ||" do
    exp = 'a || b && c || d'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse true" do
    parse( compile('do_right if loved') ).should  == rb_parse("loved and do_right")
  end
  
  it "should parse if else" do
    exp =  <<-RUBY_EVAL
    if good
      do_true
      nice
    else
      do_false
      wicked
    end
    RUBY_EVAL
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse unless" do
    exp = 'true unless false'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
end


describe 'Method definitions' do
  it "should parse method definition" do
    exp = 'def hola; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse method definition with args" do
    exp = 'def hola(a, b); c = 1; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse method definition with optionals" do
    exp = 'def hola(a = 1, b = 2); c = 1; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  # it "should parse method definition with rest" do
  #   [1, [], 0, 2, 1, -1, 0] # a, *rest
  #   [2, [], 0, 3, 2, -1, 0] # a, b, *rest
  #   exp = 'def hola(a, *rest); c = 1; end'
  #   parse( compile(exp) ).should  == rb_parse(exp)
  # end
  
  it "should several parse method definitions" do
    exp = 'def hola; end; def foo; end; def bar; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
end

describe 'Class definitions' do
  it "should parse class definition" do
    exp = 'class Klass; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end

  it "should parse class with inheritance" do
    exp = 'class Klass < Object; end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end

  it "should parse class with class ivar" do
    exp = 'class Klass < Object; @var = 1;end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
  
  it "should parse class with method definitions" do
    exp = 'class Klass < Object; def hola; end; def adios; end;end'
    parse( compile(exp) ).should  == rb_parse(exp)
  end
end

