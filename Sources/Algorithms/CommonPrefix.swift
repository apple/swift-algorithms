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

/// A sequence that produces the longest common prefix of two sequences.
public struct CommonPrefix<Base: Sequence, Other: Sequence> {
  @usableFromInline
  internal let base: Base
  
  @usableFromInline
  internal let other: Other
  
  @usableFromInline
  internal let areEquivalent: (Base.Element, Other.Element) -> Bool
  
  @inlinable
  internal init(
    base: Base,
    other: Other,
    areEquivalent: @escaping (Base.Element, Other.Element) -> Bool
  ) {
    self.base = base
    self.other = other
    self.areEquivalent = areEquivalent
  }
}

extension CommonPrefix: Sequence {
  /// The iterator for a `CommonPrefix` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: Base.Iterator
    
    @usableFromInline
    internal var other: Other.Iterator
    
    @usableFromInline
    internal let areEquivalent: (Base.Element, Other.Element) -> Bool
    
    @usableFromInline
    internal var isDone = false
    
    @inlinable
    internal init(
      base: Base.Iterator,
      other: Other.Iterator,
      areEquivalent: @escaping (Base.Element, Other.Element) -> Bool
    ) {
      self.base = base
      self.other = other
      self.areEquivalent = areEquivalent
    }
    
    public mutating func next() -> Base.Element? {
      if !isDone,
         let next = base.next(),
         let otherNext = other.next(),
         areEquivalent(next, otherNext) {
        return next
      } else {
        isDone = true
        return nil
      }
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(
      base: base.makeIterator(),
      other: other.makeIterator(),
      areEquivalent: areEquivalent)
  }
}

extension CommonPrefix: Collection where Base: Collection, Other: Collection {
  /// The index for a `CommonPrefix` collection.
  public struct Index {
    @usableFromInline
    internal let base: Base.Index
    
    @usableFromInline
    internal let other: Other.Index

    @inlinable
    internal init(base: Base.Index, other: Other.Index) {
      self.base = base
      self.other = other
    }
  }
  
  @inlinable
  internal func normalizeIndex(base: Base.Index, other: Other.Index) -> Index {
    if base != self.base.endIndex
        && other != self.other.endIndex
        && areEquivalent(self.base[base], self.other[other])
    {
      return Index(base: base, other: other)
    } else {
      return endIndex
    }
  }
  
  @inlinable
  public var startIndex: Index {
    normalizeIndex(base: base.startIndex, other: other.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(base: base.endIndex, other: other.endIndex)
  }
  
  @inlinable
  public func index(after index: Index) -> Index {
    normalizeIndex(
      base: base.index(after: index.base),
      other: other.index(after: index.other))
  }
  
  @inlinable
  public subscript(index: Index) -> Base.Element {
    base[index.base]
  }
}

extension CommonPrefix.Index: Comparable {
  @inlinable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.base == rhs.base
  }
  
  @inlinable
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.base < rhs.base
  }
}

extension CommonPrefix.Index: Hashable where Base.Index: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(base)
  }
}

extension CommonPrefix: LazySequenceProtocol where Base: LazySequenceProtocol {}
extension CommonPrefix: LazyCollectionProtocol
  where Base: LazyCollectionProtocol, Other: Collection {}

//===----------------------------------------------------------------------===//
// Sequence.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns an array of the longest common prefix of this sequence and the
  /// other sequence, according to the given equivalence function.
  ///
  ///     let characters = AnySequence("abcde")
  ///     characters.commonPrefix(with: "abce", by: ==) // ["a", "b", "c"]
  ///     characters.commonPrefix(with: "bcde", by: ==) // []
  ///
  /// - Parameters:
  ///   - other: The other sequence.
  ///   - areEquivalent: The equivalence function.
  /// - Returns: An array containing the elements in the longest common prefix
  ///   of `self` and `other`, according to `areEquivalent`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   prefix.
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    var otherIterator = other.makeIterator()
    var result: [Element] = []
    
    while let next = iterator.next(),
          let otherNext = otherIterator.next(),
          try areEquivalent(next, otherNext)
    {
      result.append(next)
    }
    
    return result
  }
}

extension Sequence where Element: Equatable {
  /// Returns an array of the longest common prefix of this sequence and the
  /// other sequence.
  ///
  ///     let characters = AnySequence("abcde")
  ///     characters.commonPrefix(with: "abce") // ["a", "b", "c"]
  ///     characters.commonPrefix(with: "bcde") // []
  ///
  /// - Parameter other: The other sequence.
  /// - Returns: An array containing the elements in the longest common prefix
  ///   of `self` and `other`.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element {
    CommonPrefix(base: self, other: other, areEquivalent: ==)
  }
}

//===----------------------------------------------------------------------===//
// LazySequenceProtocol.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol {
  /// Returns a lazy sequence of the longest common prefix of this sequence and
  /// another sequence, according to the given equivalence function.
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: @escaping (Element, Other.Element) -> Bool
  ) -> CommonPrefix<Self, Other> {
    CommonPrefix(base: self, other: other, areEquivalent: areEquivalent)
  }
}

//===----------------------------------------------------------------------===//
// Collection.commonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Returns the longest prefix of this collection that it has in common with
  /// another sequence, according to the given equivalence function.
  ///
  ///     let string = "abcde"
  ///     string.commonPrefix(with: "abce", by: ==) // "abc"
  ///     string.commonPrefix(with: "bcde", by: ==) // ""
  ///
  /// - Parameters:
  ///   - other: The other sequence.
  ///   - areEquivalent: The equivalence function.
  /// - Returns: The longest prefix of `self` that it has in common with
  ///   `other`, according to `areEquivalent`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the common prefix.
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence {
    let endIndex = endIndex
    
    var index = startIndex
    var iterator = other.makeIterator()
    
    while index != endIndex,
          let next = iterator.next(),
          try areEquivalent(self[index], next)
    {
      formIndex(after: &index)
    }
    
    return self[..<index]
  }
}

extension Collection where Element: Equatable {
  /// Returns the longest prefix of this collection that it has in common with
  /// another sequence.
  ///
  ///     let string = "abcde"
  ///     string.commonPrefix(with: "abce") // "abc"
  ///     string.commonPrefix(with: "bcde") // ""
  ///
  /// - Parameter other: The other sequence.
  /// - Returns: The longest prefix of `self` that it has in common with
  ///   `other`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   prefix.
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> SubSequence where Other.Element == Element {
    commonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// LazyCollectionProtocol.commonPrefix(with:)
//===----------------------------------------------------------------------===//

// This overload exists in the same form on `Sequence` but is necessary to
// ensure a `CommonPrefix` is returned and not a `SubSequence`.

extension LazyCollectionProtocol where Element: Equatable {
  /// Returns a lazy collection of the longest common prefix of this collection
  /// and another sequence.
  @inlinable
  public func commonPrefix<Other: Sequence>(
    with other: Other
  ) -> CommonPrefix<Self, Other> where Other.Element == Element {
    commonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// BidirectionalCollection.commonSuffix(with:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Returns the longest suffix of this collection that it has in common with
  /// another collection, according to the given equivalence function.
  ///
  ///     let string = "abcde"
  ///     string.commonSuffix(with: "acde", by: ==) // "acde"
  ///     string.commonSuffix(with: "abcd", by: ==) // ""
  ///
  /// - Parameters:
  ///   - other: The other collection.
  ///   - areEquivalent: The equivalence function.
  /// - Returns: The longest suffix of `self` that it has in common with
  ///   `other`, according to `areEquivalent`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   suffix.
  @inlinable
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> SubSequence {
    let (index, _) = try startOfCommonSuffix(with: other, by: areEquivalent)
    return self[index...]
  }
}

extension BidirectionalCollection where Element: Equatable {
  /// Returns the longest suffix of this collection that it has in common with
  /// another collection.
  ///
  ///     let string = "abcde"
  ///     string.commonSuffix(with: "acde") // "cde"
  ///     string.commonSuffix(with: "abcd") // ""
  ///
  /// - Parameter other: The other collection.
  /// - Returns: The longest suffix of `self` that it has in common with
  ///   `other`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   suffix.
  @inlinable
  public func commonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> SubSequence where Other.Element == Element {
    commonSuffix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// Collection.endOfCommonPrefix(with:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Finds the longest common prefix of this collection and another collection,
  /// according to the given equivalence function, and returns the index from
  /// each collection that marks the end of this prefix.
  ///
  ///     let string1 = "abcde"
  ///     let string2 = "abce"
  ///     let (i1, i2) = string1.endOfCommonPrefix(with: string2, by: ==)
  ///     print(string1[..<i1], string1[i1...]) // "abc", "de"
  ///     print(string2[..<i2], string2[i2...]) // "abc", "e"
  ///
  /// - Parameters:
  ///   - other: The other collection.
  ///   - areEquivalent: The equivalence function.
  /// - Returns: A pair of indices from `self` and `other` that mark the end of
  ///   their longest common prefix according to `areEquivalent`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   prefix.
  @inlinable
  public func endOfCommonPrefix<Other: Collection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index) {
    var index = startIndex
    var otherIndex = other.startIndex
    
    while index != endIndex && otherIndex != other.endIndex,
          try areEquivalent(self[index], other[otherIndex])
    {
      formIndex(after: &index)
      other.formIndex(after: &otherIndex)
    }
    
    return (index, otherIndex)
  }
}

extension Collection where Element: Equatable {
  /// Finds the longest common prefix of this collection and another collection,
  /// and returns the index from each collection that marks the end of this
  /// prefix.
  ///
  ///     let string1 = "abcde"
  ///     let string2 = "abce"
  ///     let (i1, i2) = string1.endOfCommonPrefix(with: string2)
  ///     print(string1[..<i1], string1[i1...]) // "abc", "de"
  ///     print(string2[..<i2], string2[i2...]) // "abc", "e"
  ///
  /// - Parameter other: The other collection.
  /// - Returns: A pair of indices from `self` and `other` that mark the end of
  ///   their longest common prefix.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   prefix.
  @inlinable
  public func endOfCommonPrefix<Other: Collection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element {
    endOfCommonPrefix(with: other, by: ==)
  }
}

//===----------------------------------------------------------------------===//
// BidirectionalCollection.startOfCommonSuffix(with:)
//===----------------------------------------------------------------------===//

extension BidirectionalCollection {
  /// Finds the longest common suffix of this collection and another collection,
  /// according to the given equivalence function, and returns the index from
  /// each collection that marks the start of this suffix.
  ///
  ///     let string1 = "abcde"
  ///     let string2 = "acde"
  ///     let (i1, i2) = string1.startOfCommonSuffix(with: string2, by: ==)
  ///     print(string1[..<i1], string1[i1...]) // "ab", "cde"
  ///     print(string2[..<i2], string2[i2...]) // "a", "cde"
  ///
  /// - Parameters:
  ///   - other: The other collection.
  ///   - areEquivalent: The equivalence function.
  /// - Returns: A pair of indices from `self` and `other` that mark the start
  ///   of their longest common suffix according to `areEquivalent`.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   suffix.
  @inlinable
  public func startOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other,
    by areEquivalent: (Element, Other.Element) throws -> Bool
  ) rethrows -> (Index, Other.Index) {
    let startIndex = startIndex
    let otherStartIndex = other.startIndex

    var index = endIndex
    var otherIndex = other.endIndex

    while index != startIndex && otherIndex != otherStartIndex {
      let prev = self.index(before: index)
      let otherPrev = other.index(before: otherIndex)
      
      if try !areEquivalent(self[prev], other[otherPrev]) {
        break
      }
      
      index = prev
      otherIndex = otherPrev
    }

    return (index, otherIndex)
  }
}

extension BidirectionalCollection where Element: Equatable {
  /// Finds the longest common suffix of this collection and another collection,
  /// and returns the index from each collection that marks the start of this
  /// suffix.
  ///
  ///     let string1 = "abcde"
  ///     let string2 = "acde"
  ///     let (i1, i2) = string1.startOfCommonSuffix(with: string2)
  ///     print(string1[..<i1], string1[i1...]) // "ab", "cde"
  ///     print(string2[..<i2], string2[i2...]) // "a", "cde"
  ///
  /// - Parameter other: The other collection.
  /// - Returns: A pair of indices from `self` and `other` that mark the start
  ///   of their longest common suffix.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the longest common
  ///   suffix.
  @inlinable
  public func startOfCommonSuffix<Other: BidirectionalCollection>(
    with other: Other
  ) -> (Index, Other.Index) where Other.Element == Element {
    startOfCommonSuffix(with: other, by: ==)
  }
}
