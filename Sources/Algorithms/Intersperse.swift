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
// Intersperse
//===----------------------------------------------------------------------===//

/// A sequence that presents the elements of a base sequence of elements with a
/// separator between each of those elements.
public struct InterspersedSequence<Base: Sequence> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let separator: Base.Element

  @inlinable
  internal init(base: Base, separator: Base.Element) {
    self.base = base
    self.separator = separator
  }
}

extension InterspersedSequence: Sequence {
  /// The iterator for an `InterspersedSequence` sequence.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal enum State {
      case start
      case element(Base.Element)
      case separator
    }

    @usableFromInline
    internal var iterator: Base.Iterator

    @usableFromInline
    internal let separator: Base.Element

    @usableFromInline
    internal var state = State.start

    @inlinable
    internal init(iterator: Base.Iterator, separator: Base.Element) {
      self.iterator = iterator
      self.separator = separator
    }

    @inlinable
    public mutating func next() -> Base.Element? {
      // After the start, the state flips between element and separator. Before
      // returning a separator, a check is made for the next element as a
      // separator is only returned between two elements. The next element is
      // stored to allow it to be returned in the next iteration.
      switch state {
      case .start:
        state = .separator
        return iterator.next()
      case .separator:
        guard let next = iterator.next() else { return nil }
        state = .element(next)
        return separator
      case .element(let element):
        state = .separator
        return element
      }
    }
  }

  @inlinable
  public func makeIterator() -> InterspersedSequence<Base>.Iterator {
    Iterator(iterator: base.makeIterator(), separator: separator)
  }
}

extension InterspersedSequence: Collection where Base: Collection {
  /// A position in an `InterspersedSequence` instance.
  public struct Index: Comparable {
    @usableFromInline
    internal enum Representation: Equatable {
      case element(Base.Index)
      case separator(next: Base.Index)
    }

    @usableFromInline
    internal let representation: Representation

    @inlinable
    internal init(representation: Representation) {
      self.representation = representation
    }

    @inlinable
    public static func < (lhs: Index, rhs: Index) -> Bool {
      switch (lhs.representation, rhs.representation) {
      case (.element(let li), .element(let ri)),
        (.separator(next: let li), .separator(next: let ri)),
        (.element(let li), .separator(next: let ri)):
        return li < ri
      case (.separator(next: let li), .element(let ri)):
        return li <= ri
      }
    }

    @inlinable
    internal static func element(_ index: Base.Index) -> Self {
      Self(representation: .element(index))
    }

    @inlinable
    internal static func separator(next: Base.Index) -> Self {
      Self(representation: .separator(next: next))
    }
  }

  @inlinable
  public var startIndex: Index {
    base.startIndex == base.endIndex ? endIndex : .element(base.startIndex)
  }

  @inlinable
  public var endIndex: Index {
    .separator(next: base.endIndex)
  }

  @inlinable
  public func index(after i: Index) -> Index {
    precondition(i != endIndex, "Can't advance past endIndex")
    switch i.representation {
    case .element(let index):
      return .separator(next: base.index(after: index))
    case .separator(let next):
      return .element(next)
    }
  }

  @inlinable
  public subscript(position: Index) -> Element {
    switch position.representation {
    case .element(let index): return base[index]
    case .separator: return separator
    }
  }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.representation, end.representation) {
    case (.element(let element), .separator(next: let separator)):
      return 2 * base.distance(from: element, to: separator) - 1
    case (.separator(next: let separator), .element(let element)):
      return 2 * base.distance(from: separator, to: element) + 1
    case (.element(let start), .element(let end)),
      (.separator(let start), .separator(let end)):
      return 2 * base.distance(from: start, to: end)
    }
  }

  @inlinable
  public func index(_ index: Index, offsetBy distance: Int) -> Index {
    distance >= 0
      ? offsetForward(index, by: distance)
      : offsetBackward(index, by: -distance)
  }

  @inlinable
  public func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    if distance >= 0 {
      return limit >= index
        ? offsetForward(index, by: distance, limitedBy: limit)
        : offsetForward(index, by: distance)
    } else {
      return limit <= index
        ? offsetBackward(index, by: -distance, limitedBy: limit)
        : offsetBackward(index, by: -distance)
    }
  }

  @inlinable
  internal func offsetForward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetForward(i, by: distance, limitedBy: endIndex)
    else { fatalError("Index is out of bounds") }
    return index
  }

  @inlinable
  internal func offsetBackward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetBackward(i, by: distance, limitedBy: startIndex)
    else { fatalError("Index is out of bounds") }
    return index
  }

  @inlinable
  internal func offsetForward(
    _ index: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit >= index)

    switch (
      index.representation, limit.representation, distance.isMultiple(of: 2)
    ) {
    case (.element(let index), .element(let limit), true),
      (.separator(next: let index), .element(let limit), false):
      return base.index(index, offsetBy: distance / 2, limitedBy: limit)
        .map { .element($0) }

    case (.element(let index), .element(let limit), false),
      (.element(let index), .separator(next: let limit), false),
      (.separator(next: let index), .element(let limit), true),
      (.separator(next: let index), .separator(next: let limit), true):
      return base.index(index, offsetBy: (distance + 1) / 2, limitedBy: limit)
        .map { .separator(next: $0) }

    case (.element(let index), .separator(next: let limit), true),
      (.separator(next: let index), .separator(next: let limit), false):
      return base.index(index, offsetBy: distance / 2, limitedBy: limit)
        .flatMap { $0 == limit ? nil : .element($0) }
    }
  }

  @inlinable
  internal func offsetBackward(
    _ index: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance >= 0)
    assert(limit <= index)

    switch (
      index.representation, limit.representation, distance.isMultiple(of: 2)
    ) {
    case (.element(let index), .element(let limit), true),
      (.element(let index), .separator(next: let limit), true),
      (.separator(next: let index), .element(let limit), false),
      (.separator(next: let index), .separator(next: let limit), false):
      return base.index(
        index, offsetBy: -((distance + 1) / 2), limitedBy: limit
      )
      .map { .element($0) }

    case (.element(let index), .separator(next: let limit), false),
      (.separator(next: let index), .separator(next: let limit), true):
      return base.index(index, offsetBy: -(distance / 2), limitedBy: limit)
        .map { .separator(next: $0) }

    case (.element(let index), .element(let limit), false),
      (.separator(next: let index), .element(let limit), true):
      return base.index(index, offsetBy: -(distance / 2), limitedBy: limit)
        .flatMap { $0 == limit ? nil : .separator(next: $0) }
    }
  }
}

extension InterspersedSequence: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't move before startIndex")
    switch i.representation {
    case .element(let index):
      return .separator(next: index)
    case .separator(let next):
      return .element(base.index(before: next))
    }
  }
}

extension InterspersedSequence: RandomAccessCollection
where Base: RandomAccessCollection {}

extension InterspersedSequence: LazySequenceProtocol
where Base: LazySequenceProtocol {}

extension InterspersedSequence: LazyCollectionProtocol
where Base: LazySequenceProtocol & Collection {}

//===----------------------------------------------------------------------===//
// InterspersedMap
//===----------------------------------------------------------------------===//

/// A sequence over the results of applying a closure to the sequence's
/// elements, with a separator that separates each pair of adjacent transformed
/// values.
@usableFromInline
internal struct InterspersedMapSequence<Base: Sequence, Result> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let transform: (Base.Element) -> Result

  @usableFromInline
  internal let separator: (Base.Element, Base.Element) -> Result
}

extension InterspersedMapSequence: Sequence {
  @usableFromInline
  internal struct Iterator: IteratorProtocol {
    @usableFromInline
    internal enum State {
      case start
      case element(Base.Element)
      case separator(previous: Base.Element)
    }

    @usableFromInline
    internal var base: Base.Iterator

    @usableFromInline
    internal let transform: (Base.Element) -> Result

    @usableFromInline
    internal let separator: (Base.Element, Base.Element) -> Result

    @usableFromInline
    internal var state = State.start

    @inlinable
    internal init(
      base: Base.Iterator,
      transform: @escaping (Base.Element) -> Result,
      separator: @escaping (Base.Element, Base.Element) -> Result
    ) {
      self.base = base
      self.transform = transform
      self.separator = separator
    }

    @inlinable
    internal mutating func next() -> Result? {
      switch state {
      case .start:
        guard let first = base.next() else { return nil }
        state = .separator(previous: first)
        return transform(first)
      case .separator(let previous):
        guard let next = base.next() else { return nil }
        state = .element(next)
        return separator(previous, next)
      case .element(let element):
        state = .separator(previous: element)
        return transform(element)
      }
    }
  }

  @inlinable
  internal func makeIterator() -> Iterator {
    Iterator(
      base: base.makeIterator(),
      transform: transform,
      separator: separator)
  }
}

extension InterspersedMapSequence: Collection where Base: Collection {
  @usableFromInline
  internal struct Index: Comparable {
    @usableFromInline
    internal enum Representation {
      case element(Base.Index)
      case separator(previous: Base.Index, next: Base.Index)
    }

    @usableFromInline
    internal let base: Representation

    @inlinable
    internal init(representation: Representation) {
      self.base = representation
    }

    @inlinable
    internal static func element(_ index: Base.Index) -> Self {
      Self(representation: .element(index))
    }

    @inlinable
    internal static func separator(
      previous: Base.Index,
      next: Base.Index
    ) -> Self {
      Self(representation: .separator(previous: previous, next: next))
    }

    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.base, rhs.base) {
      case (.element(let lhs), .element(let rhs)),
        (.separator(_, next: let lhs), .separator(_, next: let rhs)):
        return lhs == rhs
      case (.element, .separator), (.separator, .element):
        return false
      }
    }

    @inlinable
    internal static func < (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.base, rhs.base) {
      case (.element(let lhs), .element(let rhs)),
        (.separator(_, next: let lhs), .separator(_, next: let rhs)),
        (.element(let lhs), .separator(_, next: let rhs)),
        (.separator(previous: let lhs, _), .element(let rhs)):
        return lhs < rhs
      }
    }
  }

  @inlinable
  internal var startIndex: Index {
    base.isEmpty ? endIndex : .element(base.startIndex)
  }

  @inlinable
  internal var endIndex: Index {
    .separator(previous: base.endIndex, next: base.endIndex)
  }

  @inlinable
  internal func index(after index: Index) -> Index {
    switch index.base {
    case .element(let index):
      let next = base.index(after: index)
      return .separator(previous: index, next: next)
    case .separator(_, let next):
      return .element(next)
    }
  }

  @inlinable
  internal subscript(position: Index) -> Result {
    switch position.base {
    case .element(let index):
      return transform(base[index])
    case .separator(let previous, let next):
      return separator(base[previous], base[next])
    }
  }

  @inlinable
  internal func distance(from start: Index, to end: Index) -> Int {
    switch (start.base, end.base) {
    case (.element(let lhs), .element(let rhs)),
      (.separator(_, next: let lhs), .separator(_, next: let rhs)):
      return 2 * base.distance(from: lhs, to: rhs)
    case (.element(let lhs), .separator(_, next: let rhs)):
      return 2 * base.distance(from: lhs, to: rhs) - 1
    case (.separator(_, next: let lhs), .element(let rhs)):
      return 2 * base.distance(from: lhs, to: rhs) + 1
    }
  }

  @inlinable
  internal func index(_ index: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return index }

    return distance > 0
      ? offsetForward(index, by: distance)
      : offsetBackward(index, by: -distance)
  }

  @inlinable
  internal func index(
    _ index: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard distance != 0 else { return index }

    if distance > 0 {
      return limit >= index
        ? offsetForward(index, by: distance, limitedBy: limit)
        : offsetForward(index, by: distance)
    } else {
      return limit <= index
        ? offsetBackward(index, by: -distance, limitedBy: limit)
        : offsetBackward(index, by: -distance)
    }
  }

  @inlinable
  internal func offsetForward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetForward(i, by: distance, limitedBy: endIndex)
    else { fatalError("Index is out of bounds") }
    return index
  }

  @inlinable
  internal func offsetBackward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetBackward(i, by: distance, limitedBy: startIndex)
    else { fatalError("Index is out of bounds") }
    return index
  }

  @inlinable
  internal func offsetForward(
    _ index: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit >= index)

    switch (index.base, limit.base, distance.isMultiple(of: 2)) {
    case (.element(let index), .element(let limit), true),
      (.separator(_, next: let index), .element(let limit), false):
      return base.index(index, offsetBy: distance / 2, limitedBy: limit)
        .map { .element($0) }

    case (.element(let index), .element(let limit), false),
      (.element(let index), .separator(_, next: let limit), false),
      (.separator(_, next: let index), .element(let limit), true),
      (.separator(_, next: let index), .separator(_, next: let limit), true):
      return base.index(index, offsetBy: (distance - 1) / 2, limitedBy: limit)
        .flatMap {
          guard $0 != limit else { return nil }
          let next = base.index(after: $0)
          return next == base.endIndex
            ? endIndex
            : .separator(previous: $0, next: next)
        }

    case (.element(let index), .separator(_, next: let limit), true),
      (.separator(_, next: let index), .separator(_, next: let limit), false):
      return base.index(index, offsetBy: distance / 2, limitedBy: limit)
        .flatMap { $0 == limit ? nil : .element($0) }
    }
  }

  @inlinable
  internal func offsetBackward(
    _ index: Index,
    by distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit <= index)

    switch (index.base, limit.base, distance.isMultiple(of: 2)) {
    case (.element(let index), .element(let limit), true),
      (.element(let index), .separator(_, next: let limit), true),
      (.separator(_, next: let index), .element(let limit), false),
      (.separator(_, next: let index), .separator(_, next: let limit), false):
      return
        base
        .index(index, offsetBy: -((distance + 1) / 2), limitedBy: limit)
        .map { .element($0) }

    case (.element(let index), .separator(_, next: let limit), false),
      (.separator(_, next: let index), .separator(_, next: let limit), true):
      return base.index(index, offsetBy: -(distance / 2), limitedBy: limit)
        .map { .separator(previous: base.index($0, offsetBy: -1), next: $0) }

    case (.element(let index), .element(let limit), false),
      (.separator(_, next: let index), .element(let limit), true):
      return base.index(index, offsetBy: -(distance / 2), limitedBy: limit)
        .flatMap {
          $0 == limit
            ? nil
            : .separator(previous: base.index($0, offsetBy: -1), next: $0)
        }
    }
  }
}

extension InterspersedMapSequence: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  internal func index(before index: Index) -> Index {
    switch index.base {
    case .element(let index):
      let previous = base.index(before: index)
      return .separator(previous: previous, next: index)
    case .separator(let previous, let next):
      let index = next == base.endIndex ? base.index(before: next) : previous
      return .element(index)
    }
  }
}

extension InterspersedMapSequence.Index: Hashable
where Base.Index: Hashable {
  @inlinable
  internal func hash(into hasher: inout Hasher) {
    switch base {
    case .element(let base):
      hasher.combine(false)
      hasher.combine(base)
    case .separator(_, let next):
      hasher.combine(true)
      hasher.combine(next)
    }
  }
}

extension InterspersedMapSequence: LazySequenceProtocol {}
extension InterspersedMapSequence: LazyCollectionProtocol
where Base: Collection {}

//===----------------------------------------------------------------------===//
// interspersed(with:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns a sequence containing elements of this sequence with the given
  /// separator inserted in between each element.
  ///
  /// Any value of the sequence's element type can be used as the separator.
  ///
  /// ```
  /// for value in [1,2,3].interspersed(with: 0) {
  ///     print(value)
  /// }
  /// // 1
  /// // 0
  /// // 2
  /// // 0
  /// // 3
  /// ```
  ///
  /// The following shows a String being interspersed with a Character:
  /// ```
  /// let result = "ABCDE".interspersed(with: "-")
  /// print(String(result))
  /// // "A-B-C-D-E"
  /// ```
  ///
  /// - Parameter separator: Value to insert in between each of this sequence’s
  ///   elements.
  /// - Returns: The interspersed sequence of elements.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func interspersed(
    with separator: Element
  ) -> InterspersedSequence<Self> {
    InterspersedSequence(base: self, separator: separator)
  }
}

//===----------------------------------------------------------------------===//
// lazy.interspersedMap(_:with:)
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol {
  /// Returns a sequence over the results of applying a closure to the
  /// sequence's elements, with a separator that separates each pair of adjacent
  /// transformed values.
  ///
  /// The transformation closure lets you intersperse a sequence using a
  /// separator of a different type than the original's sequence's elements.
  /// Each separator is produced by a closure that is given access to the
  /// two elements in the original sequence right before and after it.
  ///
  ///     let strings = [1, 2, 2].interspersedMap(String.init,
  ///         with: { $0 == $1 ? " == " : " != " })
  ///     print(strings.joined()) // "1 != 2 == 2"
  ///
  @usableFromInline
  internal func interspersedMap<Result>(
    _ transform: @escaping (Element) -> Result,
    with separator: @escaping (Element, Element) -> Result
  ) -> InterspersedMapSequence<Elements, Result> {
    InterspersedMapSequence(
      base: elements,
      transform: transform,
      separator: separator)
  }
}
