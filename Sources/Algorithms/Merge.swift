//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A merge of two sequences with the same element type both pre-sorted by the
/// same predicate.
public struct Merge2Sequence<Base1: Sequence, Base2: Sequence>
where Base1.Element == Base2.Element
{
  /// The first sequence in this merged sequence
  @usableFromInline
  internal let base1: Base1
  
  /// The second sequence in this merged sequence
  @usableFromInline
  internal let base2: Base2
  
  /// A predicate that returns `true` if its first argument should be ordered
  /// before its second argument; otherwise, `false`.
  @usableFromInline
  internal let areInIncreasingOrder: (Base2.Element, Base1.Element) -> Bool
  
  @inlinable
  internal init(
    base1: Base1,
    base2: Base2,
    areInIncreasingOrder: @escaping (Base2.Element, Base1.Element) -> Bool
  ) {
    self.base1 = base1
    self.base2 = base2
    self.areInIncreasingOrder = areInIncreasingOrder
  }
}

extension Merge2Sequence: Sequence {
  /// The iterator for a `Merge2Sequence` instance
  public struct Iterator: IteratorProtocol {
    @usableFromInline
    internal var iterator1: Base1.Iterator
    
    @usableFromInline
    internal var iterator2: Base2.Iterator
    
    @usableFromInline
    internal let areInIncreasingOrder: (Base2.Element, Base1.Element) -> Bool
    
    @usableFromInline
    internal enum IterationState {
      case iterating
      case finished1
      case finished2
      case finished
    }
    
    @usableFromInline
    internal var iterationState: IterationState = .iterating
    
    @usableFromInline
    internal var previousElement1: Base1.Element? = nil
    
    @usableFromInline
    internal var previousElement2: Base2.Element? = nil
    
    @inlinable
    internal init(_ mergedSequence: Merge2Sequence) {
      iterator1 = mergedSequence.base1.makeIterator()
      iterator2 = mergedSequence.base2.makeIterator()
      areInIncreasingOrder = mergedSequence.areInIncreasingOrder
    }
    
    @inlinable
    public mutating func next() -> Base1.Element? {
      switch iterationState {
      case .iterating:
        switch (previousElement1 ?? iterator1.next(), previousElement2 ?? iterator2.next()) {
        case (.some(let element1), .some(let element2)):
          if areInIncreasingOrder(element2, element1) {
            previousElement1 = element1
            previousElement2 = nil
            return element2
          } else {
            previousElement1 = nil
            previousElement2 = element2
            return element1
          }
          
        case (nil, .some(let element2)):
          iterationState = .finished1
          return element2
          
        case (.some(let element1), nil):
          iterationState = .finished2
          return element1
          
        case (nil, nil):
          iterationState = .finished
          return nil
        }
        
      case .finished1:
        let element = iterator2.next()
        if element == nil {
          iterationState = .finished
        }
        return element
        
      case .finished2:
        let element = iterator1.next()
        if element == nil {
          iterationState = .finished
        }
        return element
        
      case .finished:
        return nil
      }
    }
  }
  
  @inlinable
  public func makeIterator() -> Iterator {
    Iterator(self)
  }
}

//===----------------------------------------------------------------------===//
// merge(_:_:areInIncreasingOrder:)
//===----------------------------------------------------------------------===//

/// Returns a new sequence that iterates over the two given sequences,
/// alternating between elements of the two sequences, returning the lesser of
/// the two elements, as defined by a predicate, `areInIncreasingOrder`.
///
/// You can pass any two sequences or collections that have the same element
/// type as this sequence and are pre-sorted by the given predicate. This
/// example merges two sequences of `Int`s:
///
///     let evens = stride(from: 0, to: 10, by: 2)
///     let odds = stride(from: 1, to: 10, by: 2)
///     for num in merge(evens, odds, by: <) {
///         print(num)
///     }
///     // 0
///     // 1
///     // 2
///     // 3
///     // 4
///     // 5
///     // 6
///     // 7
///     // 8
///     // 9
///
/// - Parameters:
///   - s1: The first sequence.
///   - s2: The second sequence.
///   - areInIncreasingOrder: A closure that takes an element of `s2` and `s1`,
///   respectively, and returns whether the first element should appear before
///   the second.
/// - Returns: A sequence that iterates first over the elements of `s1` and `s2`
/// in a sorted order
///
/// - Complexity: O(1)
@inlinable
public func merge<S1: Sequence, S2: Sequence>(
  _ s1: S1,
  _ s2: S2,
  areInIncreasingOrder: @escaping (S1.Element, S2.Element) -> Bool
) -> Merge2Sequence<S1, S2> where S1.Element == S2.Element {
  Merge2Sequence(
    base1: s1,
    base2: s2,
    areInIncreasingOrder: areInIncreasingOrder
  )
}

//===----------------------------------------------------------------------===//
// merge(_:_:)
//===----------------------------------------------------------------------===//

/// Returns a new sequence that iterates over the two given sequences,
/// alternating between elements of the two sequences, returning the lesser of
/// the two elements, as defined by the elements `Comparable` implementation.
///
/// You can pass any two sequences or collections that have the same element
/// type as this sequence and are `Comparable`. This example merges two
/// sequences of `Int`s:
///
///     let evens = stride(from: 0, to: 10, by: 2)
///     let odds = stride(from: 1, to: 10, by: 2)
///     for num in merge(evens, odds) {
///         print(num)
///     }
///     // 0
///     // 1
///     // 2
///     // 3
///     // 4
///     // 5
///     // 6
///     // 7
///     // 8
///     // 9
///
/// - Parameters:
///   - s1: The first sequence.
///   - s2: The second sequence.
/// - Returns: A sequence that iterates first over the elements of `s1` and `s2`
/// in a sorted order
///
/// - Complexity: O(1)
@inlinable
public func merge<S1: Sequence, S2: Sequence>(
  _ s1: S1,
  _ s2: S2
) -> Merge2Sequence<S1, S2>
where S1.Element == S2.Element, S1.Element: Comparable {
  Merge2Sequence(
    base1: s1,
    base2: s2,
    areInIncreasingOrder: <
  )
}
