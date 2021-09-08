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

//===----------------------------------------------------------------------===//
// JoinedBySequence
//===----------------------------------------------------------------------===//

/// A sequence that presents the elements of a base sequence of sequences
/// concatenated using a given separator.
public struct JoinedBySequence<Base: Sequence, Separator: Sequence>
  where Base.Element: Sequence, Base.Element.Element == Separator.Element
{
  @usableFromInline
  internal typealias Inner = FlattenSequence<InterspersedSequence<
    LazyMapSequence<Base, EitherSequence<Base.Element, Separator>>>>
  
  @usableFromInline
  internal let inner: Inner
  
  @inlinable
  internal init(base: Base, separator: Separator) {
    self.inner = base.lazy
      .map(EitherSequence.left)
      .interspersed(with: .right(separator))
      .joined()
  }
}

extension JoinedBySequence: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var inner: Inner.Iterator
    
    @inlinable
    internal init(inner: Inner.Iterator) {
      self.inner = inner
    }
    
    @inlinable
    public mutating func next() -> Base.Element.Element? {
      inner.next()
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(inner: inner.makeIterator())
  }
}

extension JoinedBySequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// JoinedByClosureSequence
//===----------------------------------------------------------------------===//

/// A sequence that presents the elements of a base sequence of sequences
/// concatenated using a given separator that depends on the sequences right
/// before and after it.
public struct JoinedByClosureSequence<Base: Sequence, Separator: Sequence>
  where Base.Element: Sequence, Base.Element.Element == Separator.Element
{
  @usableFromInline
  internal typealias Inner = FlattenSequence<InterspersedMapSequence<
    Base, EitherSequence<Base.Element, Separator>>>
  
  @usableFromInline
  internal let inner: Inner
  
  @inlinable
  internal init(
    base: Base,
    separator: @escaping (Base.Element, Base.Element) -> Separator
  ) {
    self.inner = base.lazy
      .interspersedMap(
        EitherSequence.left,
        with: { EitherSequence.right(separator($0, $1)) })
      .joined()
  }
}

extension JoinedByClosureSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var inner: Inner.Iterator
    
    @inlinable
    internal init(inner: Inner.Iterator) {
      self.inner = inner
    }
    
    @inlinable
    public mutating func next() -> Base.Element.Element? {
      inner.next()
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(inner: inner.makeIterator())
  }
}

extension JoinedByClosureSequence: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// JoinedByCollection
//===----------------------------------------------------------------------===//

/// A collection that presents the elements of a base collection of collections
/// concatenated using a given separator.
public struct JoinedByCollection<Base: Collection, Separator: Collection>
  where Base.Element: Collection, Base.Element.Element == Separator.Element
{
  @usableFromInline
  internal typealias Inner = FlattenCollection<InterspersedSequence<
    LazyMapSequence<Base, EitherSequence<Base.Element, Separator>>>>
  
  @usableFromInline
  internal let inner: Inner
  
  @inlinable
  internal init(base: Base, separator: Separator) {
    self.inner = base.lazy
      .map(EitherSequence.left)
      .interspersed(with: .right(separator))
      .joined()
  }
}

extension JoinedByCollection: Collection {
  public struct Index: Comparable {
    @usableFromInline
    internal let inner: Inner.Index
    
    @inlinable
    internal init(_ inner: Inner.Index) {
      self.inner = inner
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.inner == rhs.inner
    }
    
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.inner < rhs.inner
    }
  }
  
  @inlinable
  public var startIndex: Index {
    Index(inner.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(inner.endIndex)
  }
  
  @inlinable
  public func index(after index: Index) -> Index {
    Index(inner.index(after: index.inner))
  }
  
  @inlinable
  public subscript(position: Index) -> Base.Element.Element {
    inner[position.inner]
  }
  
  @inlinable
  public func index(_ index: Index, offsetBy distance: Int) -> Index {
    Index(inner.index(index.inner, offsetBy: distance))
  }
  
  @inlinable
  public func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    inner.index(index.inner, offsetBy: distance, limitedBy: limit.inner)
      .map(Index.init)
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    inner.distance(from: start.inner, to: end.inner)
  }
}

extension JoinedByCollection: BidirectionalCollection
  where Base: BidirectionalCollection,
        Base.Element: BidirectionalCollection,
        Separator: BidirectionalCollection
{
  @inlinable
  public func index(before index: Index) -> Index {
    Index(inner.index(before: index.inner))
  }
}

extension JoinedByCollection: LazySequenceProtocol, LazyCollectionProtocol
  where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// JoinedByClosureCollection
//===----------------------------------------------------------------------===//

/// A collection that presents the elements of a base collection of collections
/// concatenated using a given separator that depends on the collections right
/// before and after it.
public struct JoinedByClosureCollection<Base: Collection, Separator: Collection>
  where Base.Element: Collection, Base.Element.Element == Separator.Element
{
  @usableFromInline
  internal typealias Inner = FlattenCollection<InterspersedMapSequence<
    Base, EitherSequence<Base.Element, Separator>>>
  
  @usableFromInline
  internal let inner: Inner
  
  @inlinable
  internal init(
    base: Base,
    separator: @escaping (Base.Element, Base.Element) -> Separator
  ) {
    self.inner = base.lazy
      .interspersedMap(
        EitherSequence.left,
        with: { EitherSequence.right(separator($0, $1)) })
      .joined()
  }
}

extension JoinedByClosureCollection: Collection {
  public struct Index: Comparable {
    @usableFromInline
    internal let inner: Inner.Index
    
    @inlinable
    internal init(_ inner: Inner.Index) {
      self.inner = inner
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
      lhs.inner == rhs.inner
    }
    
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.inner < rhs.inner
    }
  }
  
  @inlinable
  public var startIndex: Index {
    Index(inner.startIndex)
  }
  
  @inlinable
  public var endIndex: Index {
    Index(inner.endIndex)
  }
  
  @inlinable
  public func index(after index: Index) -> Index {
    Index(inner.index(after: index.inner))
  }
  
  @inlinable
  public subscript(position: Index) -> Base.Element.Element {
    inner[position.inner]
  }
  
  @inlinable
  public func index(_ index: Index, offsetBy distance: Int) -> Index {
    Index(inner.index(index.inner, offsetBy: distance))
  }
  
  @inlinable
  public func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    inner.index(index.inner, offsetBy: distance, limitedBy: limit.inner)
      .map(Index.init)
  }
  
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    inner.distance(from: start.inner, to: end.inner)
  }
}

extension JoinedByClosureCollection: BidirectionalCollection
  where Base: BidirectionalCollection,
        Base.Element: BidirectionalCollection,
        Separator: BidirectionalCollection
{
  @inlinable
  public func index(before index: Index) -> Index {
    Index(inner.index(before: index.inner))
  }
}

extension JoinedByClosureCollection: LazyCollectionProtocol {}

//===----------------------------------------------------------------------===//
// Sequence.joined(by:)
//===----------------------------------------------------------------------===//

extension Sequence where Element: Sequence {
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the given separator between each sequence.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: 100) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 100, 3, 4, 100, 5, 6
  @inlinable
  public func joined(by separator: Element.Element)
    -> JoinedBySequence<Self, CollectionOfOne<Element.Element>>
  {
    joined(by: CollectionOfOne(separator))
  }
  
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the given separator between each sequence.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: [100, 200]) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 100, 200, 3, 4, 100, 200, 5, 6
  @inlinable
  public func joined<Separator>(
    by separator: Separator
  ) -> JoinedBySequence<Self, Separator>
    where Separator: Collection, Separator.Element == Element.Element
  {
    JoinedBySequence(base: self, separator: separator)
  }
  
  @inlinable
  internal func _joined(
    by update: (inout [Element.Element], Element, Element) throws -> Void
  ) rethrows -> [Element.Element] {
    var iterator = makeIterator()
    guard let first = iterator.next() else { return [] }
    
    var result = Array(first)
    var previous = first
    
    while let next = iterator.next() {
      try update(&result, previous, next)
      result.append(contentsOf: next)
      previous = next
    }
    
    return result
  }
  
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the separator produced by the closure between each sequence.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: { $0.last! * $1.first! }) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 6, 3, 4, 20, 5, 6
  @inlinable
  public func joined(
    by separator: (Element, Element) throws -> Element.Element
  ) rethrows -> [Element.Element] {
    try _joined(by: { $0.append(try separator($1, $2)) })
  }
  
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the separator produced by the closure between each sequence.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: { [100 * $0.last!, 100 * $1.first!] }) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 200, 300, 3, 4, 400, 500, 5, 6
  @inlinable
  public func joined<Separator>(
    by separator: (Element, Element) throws -> Separator
  ) rethrows -> [Element.Element]
    where Separator: Sequence, Separator.Element == Element.Element
  {
    try _joined(by: { $0.append(contentsOf: try separator($1, $2)) })
  }
}

//===----------------------------------------------------------------------===//
// LazySequenceProtocol.joined(by:)
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol where Element: Sequence {
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the separator produced by the closure between each sequence.
  @inlinable
  public func joined(
    by separator: @escaping (Element, Element) -> Element.Element
  ) -> JoinedByClosureSequence<Elements, CollectionOfOne<Element.Element>> {
    joined(by: { CollectionOfOne(separator($0, $1)) })
  }
  
  /// Returns the concatenation of the elements in this sequence of sequences,
  /// inserting the separator produced by the closure between each sequence.
  @inlinable
  public func joined<Separator>(
    by separator: @escaping (Element, Element) -> Separator
  ) -> JoinedByClosureSequence<Elements, Separator> {
    JoinedByClosureSequence(base: elements, separator: separator)
  }
}

//===----------------------------------------------------------------------===//
// Collection.joined(by:)
//===----------------------------------------------------------------------===//

extension Collection where Element: Collection {
  /// Returns the concatenation of the elements in this collection of
  /// collections, inserting the given separator between each collection.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: 100) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 100, 3, 4, 100, 5, 6
  @inlinable
  public func joined(by separator: Element.Element)
    -> JoinedByCollection<Self, CollectionOfOne<Element.Element>>
  {
    joined(by: CollectionOfOne(separator))
  }
  
  /// Returns the concatenation of the elements in this collection of
  /// collections, inserting the given separator between each collection.
  ///
  ///     for x in [[1, 2], [3, 4], [5, 6]].joined(by: [100, 200]) {
  ///         print(x)
  ///     }
  ///     // 1, 2, 100, 200, 3, 4, 100, 200, 5, 6
  @inlinable
  public func joined<Separator>(by separator: Separator)
    -> JoinedByCollection<Self, Separator>
  {
    JoinedByCollection(base: self, separator: separator)
  }
}

//===----------------------------------------------------------------------===//
// LazySequenceProtocol.joined(by:) where Self: Collection
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol where Elements: Collection, Element: Collection {
  /// Returns the concatenation of the elements in this collection of
  /// collections, inserting the separator produced by the closure between each
  /// sequence.
  @inlinable
  public func joined(
    by separator: @escaping (Element, Element) -> Element.Element
  ) -> JoinedByClosureCollection<Elements, CollectionOfOne<Element.Element>> {
    joined(by: { CollectionOfOne(separator($0, $1)) })
  }
  
  /// Returns the concatenation of the elements in this collection of
  /// collections, inserting the separator produced by the closure between each
  /// sequence.
  @inlinable
  public func joined<Separator>(
    by separator: @escaping (Element, Element) -> Separator
  ) -> JoinedByClosureCollection<Elements, Separator> {
    JoinedByClosureCollection(base: elements, separator: separator)
  }
}
