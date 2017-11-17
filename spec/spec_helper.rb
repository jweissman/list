require 'rspec'
require 'pry'
require 'list' #/version'

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
end

# class IntVector3 < Vector[3,Int]
# end
