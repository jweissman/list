# list

* [Homepage](https://rubygems.org/gems/list)
* [Documentation](http://rubydoc.info/gems/list/frames)

[![Code Climate GPA](https://codeclimate.com/github/jweissman/list/badges/gpa.svg)](https://codeclimate.com/github/jweissman/list)

## Description

Type-validating lists and vectors for Ruby.

## Features

  - [x] An easy automatic collection wrapper with `List[...]`
  - [x] Print warnings (and optionally throws errors) if an element would be added that is not of the specified type
  - [x] Inheritable with `class MyData < List[] ...`
  - [x] Vectors
  - [x] Tuples
  - [x] OneOf[...]
  - [x] Record[ field: Class...]
  - [x] RespondsTo[ ... ] -- support ducktyping
  - [x] Functions (method sigs -- input/output?) -- Function[ fn, Vector[3, Int] => List[Int] ]
  - [x] Recursive type definitions
  - [ ] Parameterized types (Typeclasses)
  - [ ] Dynamic (lazy?)
  - [ ] Abstracting over types / Something with eigenclasses? (GADTs?)

## Examples

Simple use cases involve using `List[]` to make a collection wrapper around
some basic type.

    require 'list'

    # create a new class which is a collection wrapper
    IntegerCollection = List[Integer]

    # should act largely like an array
    xs = IntegerCollection.new(1,2,3)
    xs.map(&:double) # => [4,5,6]

These wrappers can of course participate in class inheritance.

    # Really shines when you apply OO:
    # We can interact with array as implicit receiver
    class DataSet < List[Integer]
      def sum
        inject(&:+)
      end

      def mean
        sum / count
      end
    end

    ys = DataSet.new(4,6)
    ys.mean # => 5

Tuples bind several types together.

    Point = Tuple[Int,Int]

    class Points < List[Point]
      include Arithmetic
      def center
        xs = map(&:first)
        ys = map(&:second)
        [ average(xs), average(ys) ]
      end
    end

A vector is a list which validates length.

    Point3 = Vector[3, Int]
    origin = Point3[0,0,0]
    expect(origin.first).to eq(0)

A record builds a type-validated keyword 'struct'

    class Animal < Record[ species: String, genus: String ]
      def nomenclature
        [ genus, species ].join(' ')
      end
    end

Construct recursive data types with Datatype

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


## Requirements

  - Ruby

## Install

    $ gem install list

## Synopsis

    $ list

## Copyright

Copyright (c) 2017 Joseph Weissman

See {file:LICENSE.txt} for details.
