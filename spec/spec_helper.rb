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

###
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
