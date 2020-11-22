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
