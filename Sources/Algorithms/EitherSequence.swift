//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2021 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// Either
//===----------------------------------------------------------------------===//

/// A general-purpose sum type.
@usableFromInline
internal enum Either<Left, Right> {
  case left(Left)
  case right(Right)
}

extension Either: Equatable where Left: Equatable, Right: Equatable {
  @usableFromInline
  internal static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs == rhs
    case let (.right(lhs), .right(rhs)):
      return lhs == rhs
    case (.left, .right), (.right, .left):
      return false
    }
  }
}

extension Either: Comparable where Left: Comparable, Right: Comparable {
  @usableFromInline
  internal static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.left(lhs), .left(rhs)):
      return lhs < rhs
    case let (.right(lhs), .right(rhs)):
      return lhs < rhs
    case (.left, .right):
      return true
    case (.right, .left):
      return false
    }
  }
}

//===----------------------------------------------------------------------===//
// EitherSequence
//===----------------------------------------------------------------------===//

/// A sequence that has one of the two specified types.
@usableFromInline
internal enum EitherSequence<Left: Sequence, Right: Sequence>
  where Left.Element == Right.Element
{
  case left(Left)
  case right(Right)
}

extension EitherSequence: Sequence {
  @usableFromInline
  internal struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var left: Left.Iterator?
    
    @usableFromInline
    internal var right: Right.Iterator?
    
    @inlinable
    internal mutating func next() -> Left.Element? {
      left?.next() ?? right?.next()
    }
  }
  
  @usableFromInline
  internal func makeIterator() -> Iterator {
    switch self {
    case .left(let left):
      return Iterator(left: left.makeIterator(), right: nil)
    case .right(let right):
      return Iterator(left: nil, right: right.makeIterator())
    }
  }
}

extension EitherSequence: Collection
  where Left: Collection, Right: Collection, Left.Element == Right.Element
{
  @usableFromInline
  internal typealias Index = Either<Left.Index, Right.Index>

  @inlinable
  internal var startIndex: Index {
    switch self {
    case .left(let s):
      return .left(s.startIndex)
    case .right(let s):
      return .right(s.startIndex)
    }
  }

  @inlinable
  internal var endIndex: Index {
    switch self {
    case .left(let s):
      return .left(s.endIndex)
    case .right(let s):
      return .right(s.endIndex)
    }
  }

  @inlinable
  internal subscript(position: Index) -> Element {
    switch (self, position) {
    case let (.left(s), .left(i)):
      return s[i]
    case let (.right(s), .right(i)):
      return s[i]
    default:
      fatalError()
    }
  }

  @inlinable
  internal func index(after i: Index) -> Index {
    switch (self,i) {
    case let (.left(s), .left(i)):
      return .left(s.index(after: i))
    case let (.right(s), .right(i)):
      return .right(s.index(after: i))
    default:
      fatalError()
    }
  }

  @inlinable
  internal func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    switch (self, i, limit) {
    case let (.left(s), .left(i), .left(limit)):
      return s.index(i, offsetBy: distance, limitedBy: limit).map { .left($0) }
    case let (.right(s), .right(i), .right(limit)):
      return s.index(i, offsetBy: distance, limitedBy: limit).map { .right($0) }
    default:
      fatalError()
    }
  }

  @inlinable
  internal func index(_ i: Index, offsetBy distance: Int) -> Index {
    switch (self, i) {
    case let (.left(s), .left(i)):
      return .left(s.index(i, offsetBy: distance))
    case let (.right(s), .right(i)):
      return .right(s.index(i, offsetBy: distance))
    default:
      fatalError()
    }
  }

  @inlinable
  internal func distance(from start: Index, to end: Index) -> Int {
    switch (self, start, end) {
    case let (.left(s), .left(i), .left(j)):
      return s.distance(from: i, to: j)
    case let (.right(s), .right(i), .right(j)):
      return s.distance(from: i, to: j)
    default:
      fatalError()
    }
  }
}

extension EitherSequence: BidirectionalCollection
  where Left: BidirectionalCollection, Right: BidirectionalCollection
{
  @inlinable
  internal func index(before i: Index) -> Index {
    switch (self, i) {
    case let (.left(s), .left(i)):
      return .left(s.index(before: i))
    case let (.right(s), .right(i)):
      return .right(s.index(before: i))
    default:
      fatalError()
    }
  }
}

extension EitherSequence: RandomAccessCollection
  where Left: RandomAccessCollection, Right: RandomAccessCollection {}
