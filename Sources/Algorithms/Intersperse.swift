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

/// A sequence that presents the elements of a base sequence of elements
/// with a separator between each of those elements.
public struct Intersperse<Base: Sequence> {
  let base: Base
  let separator: Base.Element
}

extension Intersperse: Sequence {
  /// The iterator for an `Intersperse` sequence.
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    let separator: Base.Element
    var state = State.start

    enum State {
      case start
      case element(Base.Element)
      case separator
    }

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

  public func makeIterator() -> Intersperse<Base>.Iterator {
    Iterator(iterator: base.makeIterator(), separator: separator)
  }
}

extension Intersperse: Collection where Base: Collection {
  public struct Index: Comparable {
    enum Kind: Comparable {
      case element
      case separator(next: Base.Index)
    }
    let index: Base.Index
    let kind: Kind

    public static func < (lhs: Index, rhs: Index) -> Bool {
      (lhs.index, lhs.kind) < (rhs.index, rhs.kind)
    }
  }

  public var startIndex: Index {
    Index(index: base.startIndex, kind: .element)
  }

  public var endIndex: Index {
    Index(index: base.endIndex, kind: .element)
  }

  public func index(after i: Index) -> Index {
    switch i.kind {
    case .element:
      let next = base.index(after: i.index)
      return next == base.endIndex
        ? endIndex
        : Index(index: i.index, kind: .separator(next: next))
    case .separator(let next):
      return Index(index: next, kind: .element)
    }
  }

  public subscript(position: Index) -> Element {
    switch position.kind {
    case .element: return base[position.index]
    case .separator: return separator
    }
  }
}

extension Intersperse: BidirectionalCollection
  where Base: BidirectionalCollection
{
  public func index(before i: Index) -> Index {
    switch i.kind {
    case .element where i.index == base.endIndex:
      return Index(index: base.index(before: i.index), kind: .element)
    case .element:
      return Index(index: base.index(before: i.index), kind: .separator(next: i.index))
    case .separator:
      return Index(index: i.index, kind: .element)
    }
  }
}

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
  public func interspersed(with separator: Element) -> Intersperse<Self> {
    Intersperse(base: self, separator: separator)
  }
}
