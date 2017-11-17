require 'spec_helper'
require 'list'

describe List::Collection do
  before(:all) do
    List::Configuration.validate! # set lists to raise errors
  end

  it 'should validate' do
    expect(List::Configuration).to be_validating

    ints = List[Integer].new
    ints << 2
    ints << 5
    expect { ints << 'nope' }.to raise_error(List::InvalidItemClassError)
  end

  it 'should be a reasonable list' do
    nums = ListOfNumbers.new

    nums.push 4
    nums.push 6

    expect(nums.mean).to eq(5)

    expect(nums.select { |n| n < 5 }.to_a).to eq([4])
  end

  it 'should handle strings' do
    strs = ListOfStrings.new

    strs.push 'xylophone'
    strs.push 'countersurveillance'
    strs.push 'honorabilitudinous'

    # should work like an array
    strs << 'hexacyclomethanicarbonate'

    expect(strs.longest).to eq('hexacyclomethanicarbonate')
    expect(strs.to_s).to eq(<<-TEXT
- xylophone
- countersurveillance
- honorabilitudinous
- hexacyclomethanicarbonate
TEXT
)

    # doesn't accept ints
    expect{strs << 1}.to raise_error(List::InvalidItemClassError)
  end

  it 'cannot create a collection with wrong typed elements' do
    hash_set = ListOfHashes.new
    hash_set.push({hello: 'world'})
    expect(hash_set.first).to eq({hello: 'world'})

    # broken_hash_set
    expect {
      ListOfHashes.new('a', 1)
    }.to raise_error(List::InvalidItemClassError)
  end
end

describe 'Tuple[]' do
  it 'is a tuple' do
    point = PairOfInts.new(5,5)
    expect(point.x).to eq(5)

    expect { PairOfInts.new('zero', 0.0) }.to raise_error(Tuple::InvalidValueClassError)
  end

  it 'can make a list of tuples' do
    # both ways of constructing points give the same point
    expect(Point.new(0,0)).to eq(Point[0,0])

    xys = Points.new
    xys.push(Point[0,10])
    xys.push(Point[10,0])
    expect(xys.center).to eq([5,5])
  end
end

describe 'Vector[]' do
  it 'is a vector' do
    Point3 = Vector[3, Int]
    origin = Point3[0,0,0]
    expect(origin.first).to eq(0)

    expect { Point3[1,2] }.to raise_error(List::InvalidVectorLengthError)
  end
end
