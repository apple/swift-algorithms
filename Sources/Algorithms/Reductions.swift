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

  /// Returns a sequence containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].lazy.reductions(0, +)
  /// print(Array(runningTotal))
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: A sequence of the initial value followed by the reduced
  /// elements.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func reductions<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> ExclusiveReductionsSequence<Result, Self> {
    return reductions(into: initial) { result, element in
      result = transform(result, element)
    }
  }

  /// Returns a sequence containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].lazy.reductions(into: 0, +)
  /// print(Array(runningTotal))
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: A sequence of the initial value followed by the reduced
  /// elements.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func reductions<Result>(
    into initial: Result,
    _ transform: @escaping (inout Result, Element) -> Void
  ) -> ExclusiveReductionsSequence<Result, Self> {
    ExclusiveReductionsSequence(base: self, initial: initial, transform: transform)
  }
}

extension Sequence {

  /// Returns an array containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].reductions(0, +)
  /// print(runningTotal)
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// When `reductions(_:_:)` is called, the following steps occur:
  ///
  ///   1. The `initial` result is added to an array of results.
  ///   2. The `transform` closure is called with the `initial` result and the
  ///   first element of the sequence, appending the result to the array.
  ///   3. The closure is called again repeatedly with the updated accumulating
  ///   result and each element of the sequence, adding each result to the
  ///   array.
  ///   4. When the sequence is exhausted, the results array is returned to the
  ///   caller.
  ///
  ///   If the sequence has no elements, `transform` is never executed and
  ///   an array containing only the `initial` result is returned.
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: An array of the initial value followed by the reduced elements.
  ///
  /// - Complexity: O(_n_), where _n_ is the length of the sequence.
  @inlinable
  public func reductions<Result>(
    _ initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result] {
    return try reductions(into: initial) { result, element in
      result = try transform(result, element)
    }
  }

  /// Returns an array containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].reductions(into: 0, +)
  /// print(runningTotal)
  ///
  /// // prints [0, 1, 3, 6, 10]
  /// ```
  ///
  /// When `reductions(into:_:_)` is called, the following steps occur:
  ///
  ///   1. The `initial` result is added to an array of results.
  ///   2. The `transform` closure is called with the `initial` result and the
  ///   first element of the sequence, appending the result to the array.
  ///   3. The closure is called again repeatedly with the updated accumulating
  ///   result and each element of the sequence, adding each result to the
  ///   array.
  ///   4. When the sequence is exhausted, the results array is returned to the
  ///   caller.
  ///
  ///   If the sequence has no elements, `transform` is never executed and
  ///   an array containing only the `initial` result is returned.
  ///
  /// - Parameters:
  ///   - initial: The value to use as the initial value.
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: An array of the initial value followed by the reduced elements.
  ///
  /// - Complexity: O(_n_), where _n_ is the length of the sequence.
  @inlinable
  public func reductions<Result>(
    into initial: Result,
    _ transform: (inout Result, Element) throws -> Void
  ) rethrows -> [Result] {

    var output = [Result]()
    output.reserveCapacity(underestimatedCount + 1)
    output.append(initial)

    var initial = initial
    for element in self {
      try transform(&initial, element)
      output.append(initial)
    }

    return output
  }
}

/// A sequence of applying a transform to the element of a sequence and the
/// previously transformed result.
public struct ExclusiveReductionsSequence<Result, Base: Sequence> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let initial: Result

  @usableFromInline
  internal let transform: (inout Result, Base.Element) -> Void

  @inlinable
  internal init(
    base: Base,
    initial: Result,
    transform: @escaping (inout Result, Base.Element) -> Void
  ) {
    self.base = base
    self.initial = initial
    self.transform = transform
  }
}

extension ExclusiveReductionsSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator: Base.Iterator

    @usableFromInline
    internal var current: Result?

    @usableFromInline
    internal let transform: (inout Result, Base.Element) -> Void

    @inlinable
    internal init(
      iterator: Base.Iterator,
      current: Result? = nil,
      transform: @escaping (inout Result, Base.Element) -> Void
    ) {
      self.iterator = iterator
      self.current = current
      self.transform = transform
    }

    @inlinable
    public mutating func next() -> Result? {
      guard let result = current else { return nil }
      current = iterator.next().map { element in
        var result = result
        transform(&result, element)
        return result
      }
      return result
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             current: initial,
             transform: transform)
  }
}

extension ExclusiveReductionsSequence: Collection where Base: Collection {
  public struct Index: Comparable {
    @usableFromInline
    internal let representation: ReductionsIndexRepresentation<Base.Index, Result>

    @inlinable
    internal init(
      _ representation: ReductionsIndexRepresentation<Base.Index, Result>
    ) {
      self.representation = representation
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.representation < rhs.representation
    }
  }

  @inlinable
  public var startIndex: Index { Index(.start) }

  @inlinable
  public var endIndex: Index { Index(.end) }

  @inlinable
  public subscript(position: Index) -> Result {
    switch position.representation {
    case .start: return initial
    case .base(_, let result): return result
    case .end: fatalError("Cannot get element of end index.")
    }
  }

  @inlinable
  public func index(after i: Index) -> Index {
    func index(base index: Base.Index, previous: Result) -> Index {
      guard index != base.endIndex else { return endIndex }
      var previous = previous
      transform(&previous, base[index])
      return Index(.base(index: index, result: previous))
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

  @inlinable
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

extension ExclusiveReductionsSequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension ExclusiveReductionsSequence: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

// MARK: - Inclusive Reductions

extension LazySequenceProtocol {

  /// Returns a sequence containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].lazy.reductions(+)
  /// print(Array(runningTotal))
  ///
  /// // prints [1, 3, 6, 10]
  /// ```
  ///
  /// - Parameters:
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: A sequence of the reduced elements.
  ///
  /// - Complexity: O(1)
  @inlinable
  public func reductions(
    _ transform: @escaping (Element, Element) -> Element
  ) -> InclusiveReductionsSequence<Self> {
    InclusiveReductionsSequence(base: self, transform: transform)
  }
}

extension Sequence {

  /// Returns an array containing the accumulated results of combining the
  /// elements of the sequence using the given closure.
  ///
  /// This can be seen as applying the reduce function to each element and
  /// providing the initial value followed by these results as a sequence.
  ///
  /// ```
  /// let runningTotal = [1, 2, 3, 4].reductions(+)
  /// print(runningTotal)
  ///
  /// // prints [1, 3, 6, 10]
  /// ```
  ///
  /// When `reductions(_:)` is called, the following steps occur:
  ///
  ///   1. The `transform` closure is called with the first and second elements
  ///   of the sequence, appending the result to an array of results.
  ///   2. The closure is called again repeatedly with the updated accumulating
  ///   result and the next element of the sequence, adding each result to the
  ///   array.
  ///   3. When the sequence is exhausted, the results array is returned to the
  ///   caller.
  ///
  ///   If the sequence has no elements, `transform` is never executed and
  ///   an empty array is returned.
  ///
  ///   If the sequence has one element, `transform` is never executed and
  ///   an array containing only that first element is returned.
  ///
  /// - Parameters:
  ///   - transform: A closure that combines the previously reduced result and
  ///   the next element in the receiving sequence.
  /// - Returns: An array of the reduced elements.
  ///
  /// - Complexity: O(_n_), where _n_ is the length of the sequence.
  @inlinable
  public func reductions(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    var iterator = makeIterator()
    guard let initial = iterator.next() else { return [] }
    return try IteratorSequence(iterator).reductions(initial, transform)
  }
}

public struct InclusiveReductionsSequence<Base: Sequence> {
  @usableFromInline
  internal let base: Base

  @usableFromInline
  internal let transform: (Base.Element, Base.Element) -> Base.Element

  @inlinable
  internal init(
    base: Base,
    transform: @escaping (Base.Element, Base.Element) -> Base.Element
  ) {
    self.base = base
    self.transform = transform
  }
}

extension InclusiveReductionsSequence: Sequence {
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator: Base.Iterator

    @usableFromInline
    internal var element: Base.Element?

    @usableFromInline
    internal let transform: (Base.Element, Base.Element) -> Base.Element

    @inlinable
    internal init(
      iterator: Base.Iterator,
      element: Base.Element? = nil,
      transform: @escaping (Base.Element, Base.Element) -> Base.Element
    ) {
      self.iterator = iterator
      self.element = element
      self.transform = transform
    }

    @inlinable
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

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(iterator: base.makeIterator(),
             transform: transform)
  }
}

extension InclusiveReductionsSequence: Collection where Base: Collection {
  public struct Index: Comparable {
    @usableFromInline
    internal let representation: ReductionsIndexRepresentation<Base.Index, Base.Element>

    @inlinable
    internal init(
      _ representation: ReductionsIndexRepresentation<Base.Index, Base.Element>
    ) {
      self.representation = representation
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
      lhs.representation < rhs.representation
    }
  }

  @inlinable
  public var startIndex: Index {
    guard base.startIndex != base.endIndex else { return endIndex }
    return Index(.start)
  }

  @inlinable
  public var endIndex: Index { Index(.end) }

  @inlinable
  public subscript(position: Index) -> Base.Element {
    switch position.representation {
    case .start: return base[base.startIndex]
    case .base(_, let result): return result
    case .end: fatalError("Cannot get element of end index.")
    }
  }

  @inlinable
  public func index(after i: Index) -> Index {
    func index(after i: Base.Index, previous: Base.Element) -> Index {
      let index = base.index(after: i)
      guard index != base.endIndex else { return endIndex }
      return Index(.base(index: index, result: transform(previous, base[index])))
    }
    switch i.representation {
    case .start:
      return index(after: base.startIndex, previous: base[base.startIndex])
    case let .base(i, element):
      return index(after: i, previous: element)
    case .end:
      fatalError("Cannot get index after end index.")
    }
  }

  @inlinable
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

extension InclusiveReductionsSequence: LazySequenceProtocol
  where Base: LazySequenceProtocol {}

extension InclusiveReductionsSequence: LazyCollectionProtocol
  where Base: LazyCollectionProtocol {}

// MARK: - ReductionsIndexRepresentation

@usableFromInline
enum ReductionsIndexRepresentation<BaseIndex: Comparable, Result> {
  case start
  case base(index: BaseIndex, result: Result)
  case end
}

extension ReductionsIndexRepresentation: Equatable {
  @inlinable
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.start, .start): return true
    case (.end, .end): return true
    case let (.base(lhs, _), .base(rhs, _)): return lhs == rhs
    default: return false
    }
  }
}

extension ReductionsIndexRepresentation: Comparable {
  @inlinable
  static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (_, .start): return false
    case (.start, _): return true
    case (.end, _): return false
    case (_, .end): return true
    case let (.base(lhs, _), .base(rhs, _)): return lhs < rhs
    }
  }
}

// MARK: - Scan

extension LazySequenceProtocol {

  @available(*, deprecated, message: "Use reductions(_:_:) instead.")
  @inlinable
  public func scan<Result>(
    _ initial: Result,
    _ transform: @escaping (Result, Element) -> Result
  ) -> ExclusiveReductionsSequence<Result, Self> {
    reductions(initial, transform)
  }

  @available(*, deprecated, message: "Use reductions(into:_:) instead.")
  @inlinable
  public func scan<Result>(
    into initial: Result,
    _ transform: @escaping (inout Result, Element) -> Void
  ) -> ExclusiveReductionsSequence<Result, Self> {
    reductions(into: initial, transform)
  }
}

extension Sequence {

  @available(*, deprecated, message: "Use reductions(_:_:) instead.")
  @inlinable
  public func scan<Result>(
    _ initial: Result,
    _ transform: (Result, Element) throws -> Result
  ) rethrows -> [Result] {
    try reductions(initial, transform)
  }

  @available(*, deprecated, message: "Use reductions(into:_:) instead.")
  @inlinable
  public func scan<Result>(
    into initial: Result,
    _ transform: (inout Result, Element) throws -> Void
  ) rethrows -> [Result] {
    try reductions(into: initial, transform)
  }
}

extension LazySequenceProtocol {

  @available(*, deprecated, message: "Use reductions(_:) instead.")
  @inlinable
  public func scan(
    _ transform: @escaping (Element, Element) -> Element
  ) -> InclusiveReductionsSequence<Self> {
    reductions(transform)
  }
}

extension Sequence {

  @available(*, deprecated, message: "Use reductions(_:) instead.")
  @inlinable
  public func scan(
    _ transform: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    try reductions(transform)
  }
}
