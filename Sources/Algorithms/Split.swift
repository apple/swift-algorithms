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

public struct SplitCollection<
  Base: Collection,
  Separator: Collection
> {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let separator: Separator
  
  @usableFromInline
  internal let maxSplits: Int

  @usableFromInline
  internal let omittingEmptySubsequences: Bool
  
  @usableFromInline
  let areEquivalent: (Base.Element, Separator.Element) -> Bool
  
  @usableFromInline
  internal var _startIndex: Index
  
  @usableFromInline
  internal init(
    base: Base,
    separator: Separator,
    maxSplits: Int,
    omittingEmptySubsequences: Bool,
    areEquivalent: @escaping (Base.Element, Separator.Element) -> Bool
  ) {
    self.base = base
    self.separator = separator
    self.maxSplits = maxSplits
    self.omittingEmptySubsequences = omittingEmptySubsequences
    self.areEquivalent = areEquivalent
    
    // Initialize the `_startIndex` property to be able to call the
    // `index(after:splits:)` instance method.
    _startIndex = Index(representation: .endIndex)
    _startIndex = index(after: base.startIndex, splits: 0)
  }
}

extension SplitCollection: Collection {
  public struct Index {
    @usableFromInline
    internal enum Representation {
      case index(
        offset: Int,
        baseRange: Range<Base.Index>,
        separatorEnd: Base.Index?)
      case endIndex
    }
    
    @usableFromInline
    internal let representation: Representation
    
    @inlinable
    internal init(representation: Representation) {
      self.representation = representation
    }
  }
  
  @inlinable
  internal func index(after lowerBound: Base.Index, splits: Int) -> Index {
    func indexFromRange(
      _ range: Range<Base.Index>,
      separatorEnd: Base.Index?
    ) -> Index? {
      if range.isEmpty && omittingEmptySubsequences {
        return nil
      } else {
        return Index(representation: .index(
          offset: splits,
          baseRange: range,
          separatorEnd: separatorEnd))
      }
    }
    
    var rangeStart = lowerBound
    
    if splits != maxSplits {
      while let separatorRange = base[rangeStart...]
              .firstRange(of: separator, by: areEquivalent)
      {
        let range = rangeStart..<separatorRange.lowerBound
        rangeStart = separatorRange.upperBound
        
        if let index = indexFromRange(range, separatorEnd: rangeStart) {
          return index
        }
      }
    }
    
    return indexFromRange(rangeStart..<base.endIndex, separatorEnd: nil)
      ?? endIndex
  }
  
  @inlinable
  public var startIndex: Index {
    _startIndex
  }
  
  @inlinable
  public var endIndex: Index {
    Index(representation: .endIndex)
  }
  
  @inlinable
  public func index(after index: Index) -> Index {
    switch index.representation {
    case .index(let offset, _, let separatorEnd?):
      return self.index(after: separatorEnd, splits: offset + 1)
    case .index(_, _, nil):
      return endIndex
    case .endIndex:
      fatalError("Can't advance past endIndex")
    }
  }
  
  @inlinable
  public subscript(index: Index) -> Base.SubSequence {
    switch index.representation {
    case .index(_, let baseRange, _):
      return base[baseRange]
    case .endIndex:
      fatalError("Can't subscript using endIndex")
    }
  }
}

extension SplitCollection.Index.Representation: Comparable, Hashable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.index(let lhs, _, _), .index(let rhs, _, _)):
      return lhs == rhs
    case (.endIndex, .endIndex):
      return true
    case (.index, .endIndex), (.endIndex, .index):
      return false
    }
  }
  
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.endIndex, _):
      return false
    case (_, .endIndex):
      return true
    case (.index(let lhs, _, _), .index(let rhs, _, _)):
      return lhs < rhs
    }
  }
  
  @inlinable
  func hash(into hasher: inout Hasher) {
    switch self {
    case .index(let offset, _, _):
      hasher.combine(offset)
    case .endIndex:
      hasher.combine(Int.max)
    }
  }
}

extension SplitCollection.Index: Comparable, Hashable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.representation == rhs.representation
  }

  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.representation < rhs.representation
  }
}

//===----------------------------------------------------------------------===//
// split(separator:)
//===----------------------------------------------------------------------===//

extension Collection {
  @inlinable
  public func split<Separator: Collection>(
    separator: Separator,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    by areEquivalent: (Element, Separator.Element) throws -> Bool
  ) rethrows -> [SubSequence] {
    precondition(maxSplits >= 0, "Must take zero or more splits")
    precondition(!separator.isEmpty)
    
    var index = startIndex
    var result: [SubSequence] = []
    
    func append(upTo end: Index) {
      if !omittingEmptySubsequences || index != end {
        result.append(self[index..<end])
      }
    }
    
    while result.count != maxSplits, let range = try self[index...]
            .firstRange(of: separator, by: areEquivalent)
    {
      append(upTo: range.lowerBound)
      index = range.upperBound
    }
    
    append(upTo: endIndex)
    return result
  }
}

extension Collection where Element: Equatable {
  @inlinable
  @_disfavoredOverload // To make sure the element separator version is
                       // preferred when a string literal is used
  public func split<Separator: Collection>(
    separator: Separator,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> SplitCollection<Self, Separator>
    where Separator.Element == Element
  {
    SplitCollection(
      base: self,
      separator: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences,
      areEquivalent: ==)
  }
}

//===----------------------------------------------------------------------===//
// lazy.split(separator:)
//===----------------------------------------------------------------------===//

extension LazyCollectionProtocol {
  @inlinable
  public func split<Separator: Collection>(
    separator: Separator,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true,
    by areEquivalent: @escaping (Element, Separator.Element) -> Bool
  ) -> LazyCollection<SplitCollection<Elements, Separator>> {
    SplitCollection(
      base: elements,
      separator: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences,
      areEquivalent: areEquivalent
    ).lazy
  }
}

extension LazyCollectionProtocol where Element: Equatable {
  @inlinable
  public func split<Separator: Collection>(
    separator: Separator,
    maxSplits: Int = Int.max,
    omittingEmptySubsequences: Bool = true
  ) -> LazyCollection<SplitCollection<Elements, Separator>>
    where Separator.Element == Element
  {
    SplitCollection(
      base: elements,
      separator: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences,
      areEquivalent: ==
    ).lazy
  }
}
