def tokenize(str)
  str.gsub('(', ' ( ').gsub(')', ' ) ').split
end

def read_from_tokens(tokens)
  if tokens.count == 0
    raise "unexpected EOF while reading"
  end
  token = tokens.shift
  if '(' == token
    l = []
    while tokens[0] != ')'
      l << read_from_tokens(tokens)
    end
    tokens.shift
    return l
  elsif ')' == token
    raise "unexpected )"
  else
    return atom(token)
  end
end

def atom(token)
  a = token.to_i
  if a.to_s == token
    a
  else
    a = token.to_f
    if a.to_s == token
      a
    else
      token.to_sym
    end
  end
end

def parse(str)
  read_from_tokens(tokenize(str))
end

class Env < Hash
end

def standard_env
  env = Env.new
  
  a = {
    :+ => :+.to_proc,
    :- => :-.to_proc,
    :* => :*.to_proc,
    :/ => :/.to_proc,
    :max => lambda { |a,b| if a > b; a; else b; end; },

  }

  env.merge!(a)
end

$global_env = standard_env

def eval(x, env = $global_env)
  if x.is_a? Symbol
    return env[x]
  elsif !x.is_a? Array
    x
  else
    exps = x.map { |exp| eval(exp, env) }
    exps.shift.call(*exps)
  end
    
end

def read(prompt)
  print prompt
  gets
end

def repl(prompt = "lisp> ")
  loop {
   value = eval(parse(read(prompt)))
   puts value
  }
end

repl