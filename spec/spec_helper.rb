require 'rspec'
require 'pry'
require 'list'

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

# class IntVector3 < Vector[3,Int]
# end


Point = Tuple[Int,Int]

module Arithmetic
  def average(xs)
    sum(xs) / xs.count
  end

  def sum(xs)
    xs.inject(&:+)
  end
end

class Points < List[Point]
  include Arithmetic
  def center
    xs = map(&:first)
    ys = map(&:second)
    [ average(xs), average(ys) ]
  end
end
