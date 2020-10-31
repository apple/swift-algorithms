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
    enum Representation: Equatable {
      case element(Base.Index)
      case separator(next: Base.Index)
    }
    let representation: Representation

    public static func < (lhs: Index, rhs: Index) -> Bool {
      switch (lhs.representation, rhs.representation) {
      case let (.element(li), .element(ri)),
           let (.separator(next: li), .separator(next: ri)),
           let (.element(li), .separator(next: ri)):
        return li < ri
      case let (.separator(next: li), .element(ri)):
        return li <= ri
      }
    }

    static func element(_ index: Base.Index) -> Self {
      Self(representation: .element(index))
    }

    static func separator(next: Base.Index) -> Self {
      Self(representation: .separator(next: next))
    }
  }

  public var startIndex: Index {
    .element(base.startIndex)
  }

  public var endIndex: Index {
    .element(base.endIndex)
  }

  public func index(after i: Index) -> Index {
    switch i.representation {
    case let .element(index):
      let next = base.index(after: index)
      return next == base.endIndex ? endIndex : .separator(next: next)
    case let .separator(next):
      return .element(next)
    }
  }

  public subscript(position: Index) -> Element {
    switch position.representation {
    case .element(let index): return base[index]
    case .separator: return separator
    }
  }

  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.representation, end.representation) {
    // Handling endIndex
    case (.element(base.endIndex), .element(base.endIndex)):
      return 0
    case let (.element(element), .element(base.endIndex)):
      return 2 * base.distance(from: element, to: base.endIndex) - 1
    case let (.element(base.endIndex), .element(element)):
      return 2 * base.distance(from: base.endIndex, to: element) + 1
    case let (.separator(next: separator), .element(base.endIndex)):
      return 2 * base.distance(from: separator, to: base.endIndex)
    case let (.element(base.endIndex), .separator(next: separator)):
      return 2 * base.distance(from: base.endIndex, to: separator)
    // Non-endIndex cases
    case let (.element(element), .separator(next: separator)):
      return 2 * base.distance(from: element, to: separator) - 1
    case let (.separator(next: separator), .element(element)):
      return 2 * base.distance(from: separator, to: element) + 1
    case let (.element(start), .element(end)),
         let (.separator(start), .separator(end)):
      return 2 * base.distance(from: start, to: end)
    }
  }
}

extension Intersperse: BidirectionalCollection
  where Base: BidirectionalCollection
{
  public func index(before i: Index) -> Index {
    switch i.representation {
    case let .element(index) where index == base.endIndex:
      return .element(base.index(before: index))
    case let .element(index):
      return .separator(next: index)
    case let .separator(next):
      return .element(base.index(before: next))
    }
  }
}

extension Intersperse: RandomAccessCollection
  where Base: RandomAccessCollection {}

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
