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
