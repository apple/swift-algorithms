//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

public struct SubSequenceFinder<Base: Collection, Other: Collection>
  where Base.Element == Other.Element, Base.Element: Equatable
{
  internal var base: Base
  internal var other: Other
  internal var firstRange: Range<Base.Index>?
  
  internal init(base: Base, other: Other, allowingOverlaps: Bool) {
    self.base = base
    self.other = other
    self.firstRange = base.firstRange(of: other)
  }
}

extension SubSequenceFinder: Collection {
  public struct Index: Comparable {
    internal enum Representation: Comparable {
      case match(Range<Base.Index>)
      case end
      
      public static func < (lhs: Representation, rhs: Representation) -> Bool {
        switch (lhs, rhs) {
        case (.match, .end):
          return true
        case (.end, _):
          return false
        case (.match(let lhs), .match(let rhs)):
          return lhs.lowerBound < rhs.lowerBound
        }
      }
    }
    
    internal var base: Representation
    
    internal static var end: Index {
      Index(base: .end)
    }
    
    private init(base: Representation) {
      self.base = base
    }
    
    internal init(_ range: Range<Base.Index>) {
      self.base = .match(range)
    }
    
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.base < rhs.base
    }
  }
  
  public var startIndex: Index {
    firstRange.map { Index($0) } ?? .end
  }
  
  public var endIndex: Index {
    .end
  }
  
  public func index(after i: Index) -> Index {
    guard case .match(let range) = i.base else {
      preconditionFailure("Can't advance past endIndex")
    }
    let startingPoint = base.index(after: range.lowerBound)
    return base[startingPoint...]
      .firstRange(of: other)
      .map { Index($0) } ?? .end
  }
  
  public subscript(position: Index) -> Range<Base.Index> {
    guard case .match(let range) = position.base else {
      preconditionFailure("Can't subscript with endIndex")
    }
    return range
  }
}

extension Collection where Element: Equatable {
  public func firstRange<Other: Collection>(of other: Other) -> Range<Index>?
    where Other.Element == Element
  {
    var searchStart = startIndex
    guard let needleFirst = other.first else { return nil }
    
    while let matchStart = self[searchStart...].firstIndex(of: needleFirst) {
      var selfPos = index(after: matchStart)
      var otherPos = other.index(after: other.startIndex)
      
      while true {
        if otherPos == other.endIndex {
          return matchStart..<selfPos
        }
        if selfPos == self.endIndex {
          return nil
        }
        if self[selfPos] != other[otherPos] {
          break
        }
        
        self.formIndex(after: &selfPos)
        other.formIndex(after: &otherPos)
      }
      
      searchStart = self.index(after: matchStart)
    }
    
    return nil
  }
  
  public func allRanges<Other: Collection>(
    of other: Other,
    allowingOverlaps: Bool = true) -> SubSequenceFinder<Self, Other>
  {
    SubSequenceFinder(base: self, other: other, allowingOverlaps: allowingOverlaps)
  }
}

extension BidirectionalCollection where Element: Equatable {
  public func lastRange<Other: BidirectionalCollection>(of other: Other) -> Range<Index>?
    where Other.Element == Element
  {
    var searchEnd = endIndex
    guard let needleLast = other.last else { return nil }
    let otherLastIndex = other.index(before: other.endIndex)
    
    while let matchEnd = self[..<searchEnd].lastIndex(of: needleLast) {
      var selfPos = matchEnd
      var otherPos = otherLastIndex
      
      while true {
        if otherPos == other.startIndex {
          return selfPos..<index(after: matchEnd)
        }
        if selfPos == self.startIndex {
          return nil
        }
        
        self.formIndex(before: &selfPos)
        other.formIndex(before: &otherPos)
        if self[selfPos] != other[otherPos] {
          break
        }
      }
      
      searchEnd = matchEnd
    }
    
    return nil
  }
}


public struct SubSequenceFinderFromEnd<Base: BidirectionalCollection, Other: BidirectionalCollection>
  where Base.Element == Other.Element, Base.Element: Equatable
{
  internal var base: Base
  internal var other: Other
  internal var lastRange: Range<Base.Index>?
  
  internal init(base: Base, other: Other, allowingOverlaps: Bool) {
    self.base = base
    self.other = other
    self.lastRange = base.lastRange(of: other)
  }
}

extension SubSequenceFinderFromEnd: Collection {
  public struct Index: Comparable {
    internal enum Representation: Comparable {
      case match(Range<Base.Index>)
      case end
      
      public static func < (lhs: Representation, rhs: Representation) -> Bool {
        switch (lhs, rhs) {
        case (.match, .end):
          return true
        case (.end, _):
          return false
        case (.match(let lhs), .match(let rhs)):
          return lhs.lowerBound > rhs.lowerBound
        }
      }
    }
    
    internal var base: Representation
    
    internal static var end: Index {
      Index(base: .end)
    }
    
    private init(base: Representation) {
      self.base = base
    }
    
    internal init(_ range: Range<Base.Index>) {
      self.base = .match(range)
    }
    
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.base < rhs.base
    }
  }
  
  public var startIndex: Index {
    lastRange.map { Index($0) } ?? .end
  }
  
  public var endIndex: Index {
    .end
  }
  
  public func index(after i: Index) -> Index {
    guard case .match(let range) = i.base else {
      preconditionFailure("Can't advance past endIndex")
    }
    return base[..<range.lowerBound]
      .lastRange(of: other)
      .map { Index($0) } ?? .end
  }
  
  public subscript(position: Index) -> Range<Base.Index> {
    guard case .match(let range) = position.base else {
      preconditionFailure("Can't subscript with endIndex")
    }
    return range
  }
}

public protocol CollectionOfRanges: Collection where
  Element == Range<Bound>
{
  associatedtype Bound: Comparable
  associatedtype AscendingRangeCollection: Collection
    where AscendingRangeCollection.Element == Element
  
  func ascendingRanges() -> AscendingRangeCollection
}

extension CollectionOfRanges where Element == Range<Bound> {
  public func ascendingRanges() -> [Range<Bound>] {
    sorted(by: { $0.lowerBound < $1.lowerBound })
  }
}

extension CollectionOfRanges where AscendingRangeCollection == Self {
  public func ascendingRanges() -> Self {
    self
  }
}

extension SubSequenceFinder: CollectionOfRanges {
  public typealias Bound = Base.Index
  public typealias AscendingRangeCollection = Self
}

extension SubSequenceFinderFromEnd: CollectionOfRanges {
  public typealias Bound = Base.Index
  public typealias AscendingRangeCollection = [Range<Base.Index>]
  
  public func ascendingRanges() -> [Range<Base.Index>] {
    self.reversed()
  }
}

extension Slice: CollectionOfRanges where Base: CollectionOfRanges {
  public typealias Bound = Base.Bound
  public typealias AscendingRangeCollection = [Range<Base.Bound>]
}

extension ReversedCollection: CollectionOfRanges
  where Base: CollectionOfRanges,
        Base.AscendingRangeCollection: BidirectionalCollection
{
  public typealias Bound = Base.Bound
  public typealias AscendingRangeCollection = ReversedCollection<Base.AscendingRangeCollection>
  
  public func ascendingRanges() -> ReversedCollection<Base.AscendingRangeCollection> {
    // base.ascendingRanges().reversed()
    fatalError()
  }
}

extension LazyF
