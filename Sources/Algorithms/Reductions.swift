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

// MARK: - Exclusive Reductions

extension LazySequenceProtocol {

  /// Returns a sequence containing the results of combining the elements of
  /// the sequence using the given transform.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let values = [1, 2, 3, 4]
  /// let sequence = values.reductions(0, +)
  /// print(Array(sequence))
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: A sequence of transformed elements.
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> ExclusiveReductions<Result, Self> {
    ExclusiveReductions(base: self, initial: initial, transform: transform)
  }
}

extension Sequence {

  public func reductions<Result>(
    _ initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result] {

    var output = [Result]()
    output.reserveCapacity(underestimatedCount + 1)
    output.append(initial)

    var result = initial
    for element in self {
      result = try transform(result, element)
      output.append(result)
    }

    return output
  }
}

/// A sequence of applying a transform to the element of a sequence and the
/// previously transformed result.
public struct ExclusiveReductions<Result, Base: Sequence> {
  let base: Base
  let initial: Result
  let transform: (Result, Base.Element) -> Result
}

extension ExclusiveReductions: Sequence {
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    var current: Result?
    let transform: (Result, Base.Element) -> Result

    public mutating func next() -> Result? {
      guard let result = current else { return nil }
      current = iterator.next().map { transform(result, $0) }
      return result
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             current: initial,
             transform: transform)
  }
}

extension ExclusiveReductions: Collection where Base: Collection {
  public typealias Index = ReductionsIndex<Base.Index, Result>

  public var startIndex: Index { Index(representation: .start) }
  public var endIndex: Index { Index(representation: .end) }

  public subscript(position: Index) -> Result {
    switch position.representation {
    case .start: return initial
    case .base(_, let result): return result
    case .end: fatalError("Cannot get element of end index.")
    }
  }

  public func index(after i: Index) -> Index {
    func index(base index: Base.Index, previous: Result) -> Index {
      guard index != base.endIndex else { return endIndex }
      return .base(index: index, result: transform(previous, base[index]))
    }
    switch i.representation {
    case .start:
      return index(base: base.startIndex, previous: initial)
    case let .base(i, result):
      return index(base: base.index(after: i), previous: result)
    case .end:
      fatalError("Cannot get index after end index.")
    }
  }

  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.representation, end.representation) {
    case (.start, .start):
      return 0
    case let (.start, .base(index, _)):
      return base.distance(from: base.startIndex, to: index) + 1
    case (.start, .end):
      return base.distance(from: base.startIndex, to: base.endIndex) + 1
    case let (.base(index, _), .start):
      return base.distance(from: index, to: base.startIndex) - 1
    case let (.base(start, _), .base(end, _)):
      return base.distance(from: start, to: end)
    case let (.base(index, _), .end):
      return base.distance(from: index, to: base.endIndex)
    case (.end, .start):
      return base.distance(from: base.endIndex, to: base.startIndex) - 1
    case let (.end, .base(index, _)):
      return base.distance(from: base.endIndex, to: index)
    case (.end, .end):
      return 0
    }
  }
}

extension ExclusiveReductions: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension ExclusiveReductions: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

// MARK: - Inclusive Reductions

extension LazySequenceProtocol {

  public func reductions(
    _ transform: @escaping (Element, Element) -> Element
  ) -> InclusiveReductions<Self> {
    InclusiveReductions(base: self, transform: transform)
  }
}

extension Sequence {
  public func reductions(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    guard let initial = iterator.next() else { return [] }
    return try IteratorSequence(iterator).reductions(initial, transform)
  }
}

public struct InclusiveReductions<Base: Sequence> {
  let base: Base
  let transform: (Base.Element, Base.Element) -> Base.Element
}

extension InclusiveReductions: Sequence {
  public struct Iterator: IteratorProtocol {
    var iterator: Base.Iterator
    var element: Base.Element?
    let transform: (Base.Element, Base.Element) -> Base.Element

    public mutating func next() -> Base.Element? {
      guard let previous = element else {
        element = iterator.next()
        return element
      }
      guard let next = iterator.next() else { return nil }
      element = transform(previous, next)
      return element
    }
  }

  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             transform: transform)
  }
}

extension InclusiveReductions: Collection where Base: Collection {
  public typealias Index = ReductionsIndex<Base.Index, Base.Element>

  public var startIndex: Index {
    guard base.startIndex != base.endIndex else { return endIndex }
    return Index(representation: .start)
  }

  public var endIndex: Index {
    Index(representation: .end)
  }

  public subscript(position: Index) -> Base.Element {
    switch position.representation {
    case .start: return base[base.startIndex]
    case .base(_, let result): return result
    case .end: fatalError("Cannot get element of end index.")
    }
  }

  public func index(after i: Index) -> Index {
    func index(base index: Base.Index, previous: Base.Element) -> Index {
      guard index != base.endIndex else { return endIndex }
      return .base(index: index, result: transform(previous, base[index]))
    }
    switch i.representation {
    case .start:
      let i = base.startIndex
      return index(base: base.index(after: i), previous: base[i])
    case let .base(i, element):
      return index(base: base.index(after: i), previous: element)
    case .end:
      fatalError("Cannot get index after end index.")
    }
  }

  public func distance(from start: Index, to end: Index) -> Int {
    switch (start.representation, end.representation) {
    case (.start, .start):
      return 0
    case let (.start, .base(index, _)):
      return base.distance(from: base.startIndex, to: index)
    case (.start, .end):
      return base.distance(from: base.startIndex, to: base.endIndex)
    case let (.base(index, _), .start):
      return base.distance(from: index, to: base.startIndex)
    case let (.base(start, _), .base(end, _)):
      return base.distance(from: start, to: end)
    case let (.base(index, _), .end):
      return base.distance(from: index, to: base.endIndex)
    case (.end, .start):
      return base.distance(from: base.endIndex, to: base.startIndex)
    case let (.end, .base(index, _)):
      return base.distance(from: base.endIndex, to: index)
    case (.end, .end):
      return 0
    }
  }
}

extension InclusiveReductions: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension InclusiveReductions: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

// MARK: - Shared ReductionsIndex

public struct ReductionsIndex<BaseIndex: Comparable, Result>: Comparable {
  enum Representation {
    case start
    case base(index: BaseIndex, result: Result)
    case end
  }
  let representation: Representation

  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.representation, rhs.representation) {
    case (_, .start): return false
    case (.start, _): return true
    case (.end, _): return false
    case (_, .end): return true
    case let (.base(lhs, _), .base(rhs, _)): return lhs < rhs
    }
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs.representation, rhs.representation) {
    case (.start, .start): return true
    case (.end, .end): return true
    case let (.base(lhs, _), .base(rhs, _)): return lhs == rhs
    default: return false
    }
  }

  static func base(index: BaseIndex, result: Result) -> Self {
    Self(representation: .base(index: index, result: result))
  }
}
