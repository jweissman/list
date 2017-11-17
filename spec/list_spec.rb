require 'spec_helper'
require 'list'

describe 'List[]' do
  before(:all) do
    List.validate! # set lists to raise errors
  end

  it 'should validate' do
    expect(List).to be_validating
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
end
