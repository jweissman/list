require 'spec_helper'
require 'list'

describe List::Collection do
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

describe Tuple do
  it 'is a sum type' do
    point = PairOfInts.new(5,5)
    expect(point.x).to eq(5)

    expect { PairOfInts.new('a string', 0.0) }.to raise_error(InvalidTupleStructureError)
  end

  it 'can make a list of tuples' do
    # both ways of constructing points give the same point
    expect(Point.new(0,0)).to eq(Point[0,0])

    xys = Points.new
    xys.push(Point[0,10])
    xys.push(Point[10,0])
    expect(xys.center).to eq([5,5])
  end

  it 'has to be exact' do
    expect { PairOfInts.new(0) }.to raise_error(InvalidTupleStructureError)
  end
end

describe Vector do
  it 'is a length-restricted collection' do
    Point3 = Vector[3, Int]
    origin = Point3[0,0,0]
    expect(origin.first).to eq(0)

    expect { Point3[1,2] }.to raise_error(InvalidVectorLengthError)
  end
end

describe OneOf do
  it 'can do a list of discriminated unions' do
    number_list = List[OneOf[Int,Float]].new

    number_list.push 0.0
    number_list.push 1234

    expect { number_list.push('hi') }.to raise_error(InvalidItemClassError)
  end

  it 'manages users (example)' do
    anonymous = Anonymous.new
    sad_user = UserAccount.new(
      Username.new('sad'),
      Email.new('sadmin@corp.co')
    )

    guest = User.new(anonymous)
    expect(guest.display_name).to eq('guest-user-1')

    admin = User.new(sad_user)
    expect(admin.display_name).to eq('sad <sadmin@corp.co>')
  end
end

describe Record do
  let(:wolf) do
    Animal.new(species: 'lupus', genus: 'canis')
  end

  let(:human) do
    Animal.new(species: 'sapiens', genus: 'homo')
  end

  it 'is like a typed openstruct' do
    expect(wolf.nomenclature).to eq('canis lupus')
    expect(human.nomenclature).to eq('homo sapiens')
  end

  it 'cannot be created with invalid values' do
    expect { Animal.new(species: 4, genus: 0.0) }.to raise_error(
      List::InvalidRecordStructureError
    )
  end

  it 'cannot be assigned invalid values' do
    expect { wolf.species = 2 }.to raise_error(
      List::InvalidRecordStructureError
    )
  end

  it 'has to match the structure entirely' do
    expect { Animal.new(species: 'alien') }.to raise_error(
      List::InvalidRecordStructureError
    )
  end
end

describe RespondsTo do
  it 'ducktypes' do
    Numberish = RespondsTo[:to_i]

    Numberish.new(124)
    Numberish.new('240')
    expect { Numberish.new([1,2,3]) }.to raise_error(InvalidDucktypingError)

    numberish_list = List[Numberish].new
    numberish_list.push('1234')
    numberish_list.push(0.532)

    expect { numberish_list.push([1,2,3]) }.to raise_error(List::InvalidItemClassError)
  end
end

describe 'orchestration' do
end
