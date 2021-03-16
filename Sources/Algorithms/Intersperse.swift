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

extension Intersperse: Sequence {
  /// The iterator for an `Intersperse` sequence.
  public struct Iterator: IteratorProtocol {
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
    
    @usableFromInline
    enum State {
      case start
      case element(Base.Element)
      case separator
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
  public func makeIterator() -> Intersperse<Base>.Iterator {
    Iterator(iterator: base.makeIterator(), separator: separator)
  }
}

extension Intersperse: Collection where Base: Collection {
  /// A position in an `Intersperse` collection.
  public struct Index: Comparable {
    @usableFromInline
    enum Representation: Equatable {
      case element(Base.Index)
      case separator(next: Base.Index)
    }
    
    @usableFromInline
    internal let representation: Representation

    @inlinable
    init(representation: Representation) {
      self.representation = representation
    }

    @inlinable
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
    
    @inlinable
    static func element(_ index: Base.Index) -> Self {
      Self(representation: .element(index))
    }

    @inlinable
    static func separator(next: Base.Index) -> Self {
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
    case let .element(index):
      return .separator(next: base.index(after: index))
    case let .separator(next):
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
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    switch (i.representation, distance.isMultiple(of: 2)) {
    case (let .element(index), true):
      return .element(base.index(index, offsetBy: distance / 2))
    case (let .element(index), false):
      return .separator(next: base.index(index, offsetBy: (distance + 1) / 2))
    case (let .separator(next: index), true):
      return .separator(next: base.index(index, offsetBy: distance / 2))
    case (let .separator(next: index), false):
      return .element(base.index(index, offsetBy: (distance - 1) / 2))
    }
  }

  // TODO: Implement index(_:offsetBy:limitedBy:)
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.representation, end.representation) {
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
  @inlinable
  public func index(before i: Index) -> Index {
    precondition(i != startIndex, "Can't move before startIndex")
    switch i.representation {
    case let .element(index):
      return .separator(next: index)
    case let .separator(next):
      return .element(base.index(before: next))
    }
  }
}

extension Intersperse: RandomAccessCollection
  where Base: RandomAccessCollection {}

extension Intersperse: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension Intersperse: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

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
  public func interspersed(with separator: Element) -> Intersperse<Self> {
    Intersperse(base: self, separator: separator)
  }
}
