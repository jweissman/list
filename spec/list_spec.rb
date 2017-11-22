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

    expect { PairOfInts.new('a string', 0.0) }.to raise_error(
      InvalidTupleStructureError
    )
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
    expect { PairOfInts.new(0) }.to raise_error(
      InvalidTupleStructureError
    )
  end
end

describe Vector do
  it 'is a length-restricted collection' do
    Point3 = Vector[3, Int]
    origin = Point3[0,0,0]
    expect(origin.first).to eq(0)

    expect { Point3[1,2] }.to raise_error(InvalidVectorStructureError)
  end

  it 'is still type-restricted' do
    Point4 = Vector[4,Int]

    origin = Point4[0,0,0,0]
    expect(origin.first).to eq(0)
    expect(origin.fourth).to eq(0)

    expect {
      Point4[0,0,0,'a string']
    }.to raise_error(InvalidVectorStructureError)
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
    Numberish.new(124)
    Numberish.new('240')
    expect { Numberish.new([1,2,3]) }.to raise_error(InvalidDucktypingError)

    numberish_list = List[Numberish].new
    numberish_list.push('1234')
    numberish_list.push(0.532)

    expect { numberish_list.push([1,2,3]) }.to raise_error(List::InvalidItemClassError)
  end
end

describe Function do
  it 'typechecks function input and output' do
    good_double = ->(x) { x*2 }
    bad_double  = ->(x) { 'nope' }

    IntToInt = Function[ Int => Int ]

    expect(IntToInt.new(good_double).call(2)).to eq(4)
    expect{IntToInt.new(good_double).call('hello')}.to raise_error(InvalidFunctionArgumentError)

    expect{IntToInt.new(bad_double).call(1)}.to raise_error(InvalidFunctionResultError)
  end
end

# describe Parameterize do
# end

describe Datatype do
  it 'can construct recursive types' do
    # binding.pry
    # expect(BinaryTree.structure).to eq(
    #   # OneOf[ EmptyTree, Leaf, Tuple[Datatype[:Tree], Datatype[:Tree]] ]
    #   OneOf[ EmptyTree, Leaf, Tuple[Tree, Tree] ]
    # )
    btree = Tree.new(Empty.new)
    expect(btree.depth).to eq(0)

    btree = btree.insert(1)
    expect(btree.depth).to eq(1)

    btree = btree.insert(2)
    expect(btree.depth).to eq(2)

    # binding.pry

    # btree = Tree.new

                   # Tuple[Data[:Tree], Data[:Tree]], Empty  ] ]


    # Tree = Data[:Node, :a] = OneOf[ EmptyTree, Data[:Node, :a] ]

    # Data[:lst, :a] = EmptyList | Cons Data[:a] Data[:lst, :a]
  end

  xit 'can construct parameterized types' do
    # Data[:a] ...
  end

end

describe 'orchestration' do
  # let's use them all in composition....
  it 'can verify an array matches a list structure' do
    Activity = Tuple[Date,List[String]]
    today = Activity.new( Date.today, [ 'went shopping', 'came home' ])
    expect(today).to be_a(Activity)
    expect(today.second).to eq(['went shopping', 'came home'])
    # for construction and structure-analytic purposes we can use an array in place of a list...

  end

  # seems like this should work, but will require 'weird' changes ?
  xit 'combines lists and ducktyping' do
    class Foo; def update(*args); puts "--> foo received update with #{args}" end end
    class Bar; def update(*args); puts "--> bar received update with #{args}" end end

    class Updateable < RespondsTo[:update]
      def update!(*args)
        raise 'an error' unless update(*args)
      end
    end

    updateables = List[Updateable].new
    updateables << Foo.new
    updateables << Bar.new

    updateables.map do |updateable|
      expect(updateable).to be_a(Updateable) # ??
      updateable.update!('quux')
    end
  end
end
