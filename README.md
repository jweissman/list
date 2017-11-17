# list

* [Homepage](https://rubygems.org/gems/list)
* [Documentation](http://rubydoc.info/gems/list/frames)
* [Email](mailto:jweissman1986 at gmail.com)

[![Code Climate GPA](https://codeclimate.com/github//list/badges/gpa.svg)](https://codeclimate.com/github//list)

## Description

Type-validating lists and vectors for Ruby.

## Features

  - [x] An easy automatic collection wrapper with `List[...]`
  - [x] Print warnings (and optionally throws errors) if an element would be added that is not of the specified type
  - [x] Inheritable with `class MyData < List[] ...`
  - [x] Vectors
  - [x] Tuples
  - [x] OneOf[...]
  - [ ] Record[ field: Class...]
  - [ ] RespondsTo[ :method, :predicate? ] -- support ducktyping
  - [ ] Typeclasses?
  - [ ] Wrapped type-checked functions? (method sigs -- input/output?) -- Function[ fn, Vector[3, Int] => List[Int] ]
  - [ ] Abstracting over types / Something with eigenclasses? (GADTs?)

## Examples

    require 'list'

    # create a new class which is a collection wrapper
    IntegerCollection = List[Integer]

    # should act largely like an array
    xs = IntegerCollection.new(1,2,3)
    xs.map(&:double) # => [4,5,6]

    # Really shines when you apply OO:
    # We can interact with array as implicit receiver
    class DataSet < List[Integer]
      def sum
        inject(&:+)
      end

      def mean
        sum / count
    end

    ys = DataSet.new(4,6)
    ys.mean # => 5

    # Tuples let this all be a bit more expressive...
    Point = Tuple[Int,Int]

    class Points < List[Point]
      include Arithmetic
      def center
        xs = map(&:first)
        ys = map(&:second)
        [ average(xs), average(ys) ]
      end
    end

    # A vector is a list which validates length...
    Point3 = Vector[3, Int]
    origin = Point3[0,0,0]
    expect(origin.first).to eq(0)

## Requirements

## Install

    $ gem install list

## Synopsis

    $ list

## Copyright

Copyright (c) 2017 Joseph Weissman

See {file:LICENSE.txt} for details.
