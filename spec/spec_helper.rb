require 'rspec'
require 'pry'
require 'list'

include List
List::Configuration.validate! # set lists to raise errors

class ListOfNumbers < List[Integer]
  def sum
    inject(&:+)
  end

  def mean
    sum / count
  end
end

class ListOfStrings < List[String]
  def longest
    sort_by(&:length).reverse.first
  end

  def to_s
    map { |s| "- #{s}" }.join("\n") + "\n"
  end
end

class ListOfHashes < List[Hash]
end

# some more things...
Int = Integer
class PairOfInts < Tuple[Int,Int]
  def x; first end
  def y; second end
end


module Arithmetic
  def average(xs)
    sum(xs) / xs.count
  end

  def sum(xs)
    xs.inject(&:+)
  end
end

Point = Tuple[Int,Int]
class Points < List[Point]
  include Arithmetic
  def center
    xs = map(&:first)
    ys = map(&:second)
    [ average(xs), average(ys) ]
  end
end

### one-of (unions)
class Username < String; end
class Email < String; end
class UserAccount < Tuple[Username, Email]; end
class Anonymous; end

class User < OneOf[ UserAccount, Anonymous ]
  def display_name
    case item
    when UserAccount then "#{item.first} <#{item.second}>"
    when Anonymous then "guest-user-1"
    # look, no else
    end
  end
end

### records
#
class Animal < Record[ species: String, genus: String ]
  def nomenclature
    [ genus, species ].join(' ')
  end
end

## ducktyping
#
Numberish = RespondsTo[:to_i]


### typeclasses...
class Empty; end
class Leaf < Struct.new(:value); end

Node = Tuple[ Datatype[:Tree], Leaf, Datatype[:Tree] ]
Tree = Datatype[ :Tree, OneOf[ Empty, Leaf, Node ] ]

# -- now that Tree is defined we can just reopen...
class Tree
  def depth
    case item
    when Empty then 0
    when Leaf then 1
    when Node then
      left,_m,right=*item.values
      1+[left.depth,right.depth].max
    end
  end

  def insert(x)
    case item
    when Empty then
      Tree[ Leaf[x] ]
    when Leaf then
      m=item.value
      if x > m
        Tree[ Node[ Tree[Empty.new], item, Tree[Leaf[x]] ]]
      else
        Tree[ Node[ Tree[Leaf[x]], item, Tree[Empty.new] ]]
      end
    when Node then
      left,m,right=*item.values
      if x > m
        Tree[ Node[left, m, right.insert(x)] ]
      else
        Tree[ Node[left.insert(x), m, right] ]
      end
    end
  end
end

### wrapped functions???

### gadts???
