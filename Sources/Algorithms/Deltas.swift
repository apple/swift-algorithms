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

/// An iterator wrapper that vends the changes between each consecutive pair of
/// elements, as evaluated by some closure.
public struct DeltasIterator<Base: IteratorProtocol, Element> {
  /// The source of the operands for the differentiating closure.
  @usableFromInline
  var base: Base
  /// The closure that evaluates the difference between source elements.
  @usableFromInline
  let subtracter: (Base.Element, Base.Element) throws -> Element
  /// The last element from `base` read.
  var previous: Base.Element?

  /// Creates an iterator vending the differences between consecutive elements
  /// from the given iterator using the given closure.
  @inlinable
  init(
    _ base: Base,
    via subtracter: @escaping (Base.Element, Base.Element) throws -> Element
  ) {
    self.base = base
    self.subtracter = subtracter
  }
}

extension DeltasIterator {
  /// Advances to the next element, possibly throwing in the attempt, and
  /// returns it, or `nil` if no next element exists.
  @usableFromInline
  mutating func throwingNext() throws -> Element? {
    guard let previous = previous else {
      guard let first = base.next() else { return nil }

      self.previous = first
      return try throwingNext()
    }
    guard let current = base.next() else { return nil }
    defer { self.previous = current }

    return try subtracter(current, previous)
  }
}

extension DeltasIterator: IteratorProtocol {
  @inlinable
  public mutating func next() -> Element? {
    return try! throwingNext()
  }
}

/// A sequence wrapper that vends the changes between each consecutive pair of
/// elements, as evaluated by some closure.
public struct DeltasSequence<Base: Sequence, Element> {
  /// The source of the operands for the differentiating closure.
  public let base: Base
  /// The closure that evaluates the difference between source elements.
  @usableFromInline
  let subtracter: (Base.Element, Base.Element) throws -> Element

  /// Creates a sequence vending the differences between consecutive elements
  /// of the given sequence using the given closure.
  @inlinable
  init(
    _ base: Base,
    via subtracter: @escaping (Base.Element, Base.Element) throws -> Element
  ) {
    self.base = base
    self.subtracter = subtracter
  }
}

extension DeltasSequence: LazySequenceProtocol {
  @inlinable
  public var underestimatedCount: Int
  { Swift.max(base.underestimatedCount - 1, 0) }

  @inlinable
  public func makeIterator() -> DeltasIterator<Base.Iterator, Element> {
    return DeltasIterator(base.makeIterator(), via: subtracter)
  }
}

/// A collection wrapper presenting the changes between each consecutive pair of
/// elements, as evaluated by some closure.
public typealias DeltasCollection<T: Collection, U> = DeltasSequence<T, U>

extension DeltasSequence: Collection, LazyCollectionProtocol
where Base: Collection {
  @inlinable
  public var startIndex: Base.Index {
    let start = base.startIndex, end = base.endIndex
    guard let second = base.index(start, offsetBy: +1, limitedBy: end),
          second < end else {
      // Need at least two wrapped elements to start.
      return end
    }

    return start
  }
  @inlinable public var endIndex: Base.Index { base.endIndex }

  @inlinable
  public subscript(position: Base.Index) -> Element {
    // If position is either base.end or base.indices.last, we get a crash.
    return try! subtracter(base[base.index(after: position)], base[position])
  }
  @inlinable
  public subscript(bounds: Range<Base.Index>)
  -> DeltasSequence<Base.SubSequence, Element> {
    guard bounds.upperBound < base.endIndex else {
      return SubSequence(base[bounds.lowerBound...], via: subtracter)
    }

    return SubSequence(base[bounds.lowerBound ... bounds.upperBound],
                       via: subtracter)
  }

  @inlinable
  public func index(_ i: Base.Index, offsetBy distance: Int) -> Base.Index {
    let endPoint = distance < 0 ? startIndex : endIndex
    return index(i, offsetBy: distance, limitedBy: endPoint)!
  }
  public func index(
    _ i: Base.Index, offsetBy distance: Int, limitedBy limit: Base.Index
  ) -> Base.Index? {
    guard let result = base.index(i, offsetBy: distance, limitedBy: limit)
    else { return nil }

    if case let end = base.endIndex, result < end,
       base.index(after: result) == end {
      // Landed on the forbidden last base element, skip past it in the
      // direction of movement.
      if distance > 0 {
        return end
      } else if distance < 0 {
        return base.index(result, offsetBy: -1,
                          limitedBy: Swift.max(base.startIndex, limit))
      } else {
        preconditionFailure("Used the forbidden base index value")
      }
    } else {
      return result
    }
  }
  @inlinable
  public func distance(from start: Base.Index, to end: Base.Index) -> Int {
    var rawResult = base.distance(from: start, to: end)
    if case let baseEnd = base.endIndex, start == baseEnd || end == baseEnd {
      // We went past the forbidden last element, so take it out of the distance
      // calculation.
      rawResult -= rawResult.signum()
    }
    return rawResult
  }

  @inlinable
  public func index(after i: Base.Index) -> Base.Index {
    return index(i, offsetBy: +1)
  }
}

extension DeltasSequence: BidirectionalCollection
where Base: BidirectionalCollection {
  @inlinable
  public func index(before i: Base.Index) -> Base.Index {
    return index(i, offsetBy: -1)
  }
}

extension DeltasSequence: RandomAccessCollection
where Base: RandomAccessCollection {}

//===----------------------------------------------------------------------===//
// deltas(storingInto:via:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Differentiates the sequence by applying the given closure between each
  /// pair of consecutive elements in order, copying the results into an
  /// instance of the given collection type.
  ///
  /// When the closure is called with a pair of consecutive elements, the latter
  /// element is used as the first argument and the former element is used as
  /// the second argument.  If your closure defines its parameters' order such
  /// that the source occurs first and the destination second, wrap that closure
  /// in another that swaps the arguments' positions first.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     let deltas1 = fib.deltas(storingInto: Array.self, via: -)
  ///     let deltas2 = fib.deltas(storingInto: Array.self) { $1.distance(to: $0) }
  ///     print(deltas1, deltas2)
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13] [0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Precondition: The sequence must be finite.
  ///
  /// - Parameters:
  ///   - type: The metatype specifier for the collection to be returned.
  ///   - subtracter: The closure that computes a value needed to traverse from
  ///     the closure's second argument to its first argument.
  /// - Returns: A collection containing the changes, starting with the delta
  ///   between the first and second elements, and ending with the delta between
  ///   the next-to-last and last elements.  The collection is empty if the
  ///   receiver has less than two elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @usableFromInline
  internal func deltas<T: RangeReplaceableCollection>(
    storingInto type: T.Type,
    via subtracter: (Element, Element) throws -> T.Element
  ) rethrows -> T {
    var result = T()
    try withoutActuallyEscaping(subtracter) {
      var sequence = DeltasSequence(self, via: $0),
          iterator = sequence.makeIterator()
      result.reserveCapacity(sequence.underestimatedCount)
      while let delta = try iterator.throwingNext() {
        result.append(delta)
      }
    }
    return result
  }
}

//===----------------------------------------------------------------------===//
// deltas(via:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Differentiates the sequence into an array, formed by applying the given
  /// closure on each pair of consecutive elements in order.
  ///
  /// When the closure is called with a pair of consecutive elements, the latter
  /// element is used as the first argument and the former element is used as
  /// the second argument.  If your closure defines its parameters' order such
  /// that the source occurs first and the destination second, wrap that closure
  /// in another that swaps the arguments' positions first.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     let deltas1 = fib.deltas(via: -)
  ///     let deltas2 = fib.deltas() { $1.distance(to: $0) }
  ///     print(deltas1, deltas2)
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13] [0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Precondition: The sequence must be finite.
  ///
  /// - Parameters:
  ///   - subtracter: The closure that computes a value needed to traverse from
  ///     the closure's second argument to its first argument.
  /// - Returns: An array containing the changes, starting with the delta
  ///   between the first and second elements, and ending with the delta between
  ///   the next-to-last and last elements.  The array is empty if the receiver
  ///   has less than two elements.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func deltas<T>(via subtracter: (Element, Element) throws -> T)
  rethrows -> [T] {
    return try deltas(storingInto: Array.self, via: subtracter)
  }
}

extension LazySequenceProtocol {
  /// Differentiates this sequence into a lazily generated sequence, formed by
  /// applying the given closure on each pair of consecutive elements in order.
  ///
  /// When the closure is called with a pair of consecutive elements, the latter
  /// element is used as the first argument and the former element is used as
  /// the second argument.  If your closure defines its parameters' order such
  /// that the source occurs first and the destination second, wrap that closure
  /// in another that swaps the arguments' positions first.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     let deltas1 = fib.lazy.deltas(via: -)
  ///     let deltas2 = fib.lazy.deltas() { $1.distance(to: $0) }
  ///     print(Array(deltas1), Array(deltas2))
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13] [0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Parameters:
  ///   - subtracter: The closure that computes a value needed to traverse from
  ///     the closure's second argument to its first argument.
  /// - Returns: A lazy sequence containing the changes, starting with the delta
  ///   between the first and second elements, and ending with the delta between
  ///   the next-to-last and last elements.  The result is empty if the receiver
  ///   has less than two elements.
  @inlinable
  public func deltas<T>(via subtracter: @escaping (Element, Element) -> T)
  -> DeltasSequence<Elements, T> {
    return DeltasSequence(elements, via: subtracter)
  }
}

//===----------------------------------------------------------------------===//
// differences(), wrappedDifferences(), strides()
//
// (Note: Some Apple-SDK types use custom delta operations that share the same
// operator/method names needed below.  They don't actually conform to the
// corresponding protocols, and as such can't use the following methods.)
//===----------------------------------------------------------------------===//

extension Sequence where Element: AdditiveArithmetic {
  /// Differentiates this sequence into a lazy sequence formed by the
  /// differences between each pair of consecutive elements in order.
  ///
  /// This method uses `.lazy.deltas(via:)` with the closure being the `-`
  /// operator.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     print(Array(fib.differences()))
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Returns: A lazy sequence containing the differences, starting with the
  ///   difference between the first and second elements, and ending with the
  ///   difference between the next-to-last and last elements.  The result is
  ///   empty if the receiver has less than two elements.
  @inlinable
  public func differences() -> DeltasSequence<Self, Element> {
    return lazy.deltas(via: -)
  }
}

extension Sequence where Element: SIMD, Element.Scalar: FloatingPoint {
  /// Differentiates this sequence into a lazy sequence formed by the vector
  /// differences between each pair of consecutive elements in order.
  ///
  /// This method uses `.lazy.deltas(via:)` with the closure being the `-`
  /// operator.
  ///
  ///     let fibPairs: [SIMD2<Double>] = [[1, 1], [1, 2], [2, 3], [3, 5]]
  ///     print(Array(fibPairs.differences()))
  ///     // Prints "[SIMD2<Double>(0.0, 1.0), SIMD2<Double>(1.0, 1.0), SIMD2<Double>(1.0, 2.0)]"
  ///
  /// - Returns: A lazy sequence containing the vector-differences, starting
  ///   with the difference between the first and second elements, and ending
  ///   with the difference between the next-to-last and last elements.  The
  ///   result is empty if the receiver has less than two elements.
  @inlinable
  public func differences() -> DeltasSequence<Self, Element> {
    return lazy.deltas(via: -)
  }
}

extension Sequence where Element: FixedWidthInteger {
  /// Differentiates this sequence into a lazy sequence formed by the wrapped
  /// differences between each pair of consecutive elements in order.
  ///
  /// This method uses `.lazy.deltas(via:)` with the closure being the `&-`
  /// operator.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     print(Array(fib.wrappedDifferences()))
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Returns: A lazy sequence containing the differences, starting with the
  ///   wrapped-difference between the first and second elements, and ending
  ///   with the wrapped-difference between the next-to-last and last elements.
  ///   The result is empty if the receiver has less than two elements.
  @inlinable
  public func wrappedDifferences() -> DeltasSequence<Self, Element> {
    return lazy.deltas(via: &-)
  }
}

extension Sequence where Element: SIMD, Element.Scalar: FixedWidthInteger {
  /// Differentiates this sequence into a lazy sequence formed by the vector
  /// wrapped-differences between each pair of consecutive elements in order.
  ///
  /// This method uses `.lazy.deltas(via:)` with the closure being the `&-`
  /// operator.
  ///
  ///     let fibPairs: [SIMD2<Int>] = [[1, 1], [1, 2], [2, 3], [3, 5], [5, 8]]
  ///     print(Array(fibPairs.wrappedDifferences()))
  ///     // Prints "[SIMD2<Int>(0, 1), SIMD2<Int>(1, 1), SIMD2<Int>(1, 2), SIMD2<Int>(2, 3)]"
  ///
  /// - Returns: A lazy sequence containing the vector-differences, starting
  ///   with the wrapped-difference between the first and second elements, and
  ///   ending with the wrapped-difference between the next-to-last and last
  ///   elements.  The result is empty if the receiver has less than two
  ///   elements.
  @inlinable
  public func wrappedDifferences() -> DeltasSequence<Self, Element> {
    return lazy.deltas(via: &-)
  }
}

extension Sequence where Element: Strideable {
  /// Differentiates this sequence into a lazy sequence formed by the
  /// strides between each pair of consecutive elements in order.
  ///
  /// This method uses `.lazy.deltas(via:)` with the closure being a call to the
  /// `Strideable.distance(to:)` method.
  ///
  ///     let fib = [1, 1, 2, 3, 5, 8, 13, 21, 34]
  ///     print(Array(fib.strides()))
  ///     // Prints "[0, 1, 1, 2, 3, 5, 8, 13]"
  ///
  /// - Returns: A lazy sequence containing the strides, starting with the
  ///   distance between the first and second elements, and ending with the
  ///   distance between the next-to-last and last elements.  The result is
  ///   empty if the receiver has less than two elements.
  @inlinable
  public func strides() -> DeltasSequence<Self, Element.Stride> {
    return lazy.deltas() { $1.distance(to: $0) }
  }
}
