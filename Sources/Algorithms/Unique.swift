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

/// A sequence wrapper that leaves out duplicate elements of a base sequence.
public struct UniquedSequence<Base: Sequence, Subject: Hashable> {
  /// The base collection.
  @usableFromInline
  internal let base: Base

  /// The projection function.
  @usableFromInline
  internal let projection: (Base.Element) -> Subject

  @usableFromInline
  internal init(base: Base, projection: @escaping (Base.Element) -> Subject) {
    self.base = base
    self.projection = projection
  }
}

extension UniquedSequence: Sequence {
  /// The iterator for a `UniquedSequence` instance.
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var base: Base.Iterator

    @usableFromInline
    internal let projection: (Base.Element) -> Subject

    @usableFromInline
    internal var seen: Set<Subject> = []

    @usableFromInline
    internal init(
      base: Base.Iterator,
      projection: @escaping (Base.Element) -> Subject
    ) {
      self.base = base
      self.projection = projection
    }

    @inlinable
    public mutating func next() -> Base.Element? {
      while let element = base.next() {
        if seen.insert(projection(element)).inserted {
          return element
        }
      }
      return nil
    }
  }

  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(base: base.makeIterator(), projection: projection)
  }
}

extension UniquedSequence: LazySequenceProtocol
where Base: LazySequenceProtocol {}

//===----------------------------------------------------------------------===//
// uniqued()
//===----------------------------------------------------------------------===//

extension Sequence where Element: Hashable {
  /// Returns a sequence with only the unique elements of this sequence, in the
  /// order of the first occurrence of each unique element.
  ///
  ///     let animals = ["dog", "pig", "cat", "ox", "dog", "cat"]
  ///     let uniqued = animals.uniqued()
  ///     print(Array(uniqued))
  ///     // Prints '["dog", "pig", "cat", "ox"]'
  ///
  /// - Returns: A sequence with only the unique elements of this sequence.
  ///  .
  /// - Complexity: O(1).
  @inlinable
  public func uniqued() -> UniquedSequence<Self, Element> {
    UniquedSequence(base: self, projection: { $0 })
  }
}

extension Sequence {
  /// Returns an array with the unique elements of this sequence (as determined
  /// by the given projection), in the order of the first occurrence of each
  /// unique element.
  ///
  /// This example finds the elements of the `animals` array with unique
  /// first characters:
  ///
  ///     let animals = ["dog", "pig", "cat", "ox", "cow", "owl"]
  ///     let uniqued = animals.uniqued(on: { $0.first })
  ///     print(uniqued)
  ///     // Prints '["dog", "pig", "cat", "ox"]'
  ///
  /// - Parameter projection: A closure that transforms an element into the
  ///   value to use for uniqueness. If `projection` returns the same value for
  ///   two different elements, the second element will be excluded from the
  ///   resulting array.
  ///
  /// - Returns: An array with only the unique elements of this sequence, as
  ///   determined by the result of `projection` for each element.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued<Subject: Hashable>(
    on projection: (Element) throws -> Subject
  ) rethrows -> [Element] {
    var seen: Set<Subject> = []
    var result: [Element] = []
    for element in self {
      if seen.insert(try projection(element)).inserted {
        result.append(element)
      }
    }
    return result
  }

  /// Returns an array with the unique elements of this sequence (as determined
  /// by the given projection), using the provided closure to combine or resolve
  /// duplicate elements.
  ///
  /// As the sequence is iterated, the `combine` closure is called with the
  /// current accumulated value and the newly encountered value for any duplicate
  /// projection keys. The return value replaces the previous element in the
  /// resulting array while preserving the position of its first occurrence.
  ///
  /// - Parameters:
  ///   - projection: A closure that transforms an element into the value to use
  ///     for uniqueness.
  ///   - combine: A closure called when two elements produce the same projection
  ///     key. The closure takes the existing element and the duplicate element,
  ///     returning the combined element to retain.
  ///
  /// - Returns: An array with the unique elements in first-occurrence order.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued<Subject: Hashable>(
    on projection: (Element) throws -> Subject,
    uniquingWith combine: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    var seenIndices: [Subject: Int] = [:]
    var result: [Element] = []

    for element in self {
      let key = try projection(element)
      if let existingIndex = seenIndices[key] {
        result[existingIndex] = try combine(result[existingIndex], element)
      } else {
        seenIndices[key] = result.count
        result.append(element)
      }
    }

    return result
  }
}

extension Sequence where Element: Hashable {
  /// Returns an array with the unique elements of this sequence, using the
  /// provided closure to combine or resolve duplicate elements.
  ///
  /// - Parameter combine: A closure called when two duplicate elements are
  ///   encountered. The closure takes the existing element and the duplicate
  ///   element, returning the combined element to retain.
  ///
  /// - Returns: An array with the unique elements in first-occurrence order.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func uniqued(
    uniquingWith combine: (Element, Element) throws -> Element
  ) rethrows -> [Element] {
    try uniqued(on: { $0 }, uniquingWith: combine)
  }
}

//===----------------------------------------------------------------------===//
// lazy.uniqued()
//===----------------------------------------------------------------------===//

extension LazySequenceProtocol {
  /// Returns a lazy sequence with the unique elements of this sequence (as
  /// determined by the given projection), in the order of the first occurrence
  /// of each unique element.
  ///
  /// - Complexity: O(1).
  @inlinable
  public func uniqued<Subject: Hashable>(
    on projection: @escaping (Element) -> Subject
  ) -> UniquedSequence<Self, Subject> {
    UniquedSequence(base: self, projection: projection)
  }
}
