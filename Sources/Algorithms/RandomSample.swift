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

// For log(_:) and root(_:_:)
@_implementationOnly
import RealModule

//===----------------------------------------------------------------------===//
// randomStableSample(count:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// Randomly selects the specified number of elements from this collection,
  /// maintaining their relative order.
  ///
  /// - Parameters:
  ///   - k: The number of elements to randomly select.
  ///   - rng: The random number generator to use for the sampling.
  /// - Returns: An array of `k` random elements. If `k` is greater than this
  ///   collection's count, then this method returns the full collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func randomStableSample<G: RandomNumberGenerator>(
    count k: Int, using rng: inout G
  ) -> [Element] {
    guard k > 0 else { return [] }
    
    var remainingCount = count
    guard k < remainingCount else { return Array(self) }
    
    var result: [Element] = []
    result.reserveCapacity(k)
    
    var i = startIndex
    var countToSelect = k
    while countToSelect > 0 {
      let r = Int.random(in: 0..<remainingCount, using: &rng)
      if r < countToSelect {
        result.append(self[i])
        countToSelect -= 1
      }

      formIndex(after: &i)
      remainingCount -= 1
    }
    
    return result
  }
  
  /// Randomly selects the specified number of elements from this collection,
  /// maintaining their relative order.
  ///
  /// This method is equivalent to calling `randomStableSample(k:using:)`,
  /// passing in the system's default random generator.
  ///
  /// - Parameter k: The number of elements to randomly select.
  /// - Returns: An array of `k` random elements. If `k` is greater than this
  ///   collection's count, then this method returns the full collection.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func randomStableSample(count k: Int) -> [Element] {
    var g = SystemRandomNumberGenerator()
    return randomStableSample(count: k, using: &g)
  }
}

//===----------------------------------------------------------------------===//
// randomSample(count:)
//===----------------------------------------------------------------------===//

// These methods use Algorithm L, described in "Reservoir-Sampling
// Algorithms of Time Complexity O(n(1 + log(N/n)))":
// https://dl.acm.org/doi/pdf/10.1145/198429.198435

@usableFromInline
internal func nextW<G: RandomNumberGenerator>(
  k: Int, using rng: inout G
) -> Double {
  Double.root(.random(in: 0..<1, using: &rng), k)
}

@usableFromInline
internal func nextOffset<G: RandomNumberGenerator>(
  w: Double, using rng: inout G
) -> Int {
  let offset = Double.log(.random(in: 0..<1, using: &rng)) / .log(onePlus: -w)
  return offset < Double(Int.max) ? Int(offset) : Int.max
}

extension Collection {
  /// Randomly selects the specified number of elements from this collection.
  ///
  /// - Parameters:
  ///   - k: The number of elements to randomly select.
  ///   - rng: The random number generator to use for the sampling.
  /// - Returns: An array of `k` random elements. The returned elements may be
  ///   in any order. If `k` is greater than this collection's count, then this
  ///   method returns the full collection.
  ///
  /// - Complexity: O(*k*), where *k* is the number of elements to select, if
  ///   the collection conforms to `RandomAccessCollection`. Otherwise, O(*n*),
  ///   where *n* is the length of the collection.
  @inlinable
  public func randomSample<G: RandomNumberGenerator>(
    count k: Int, using rng: inout G
  ) -> [Element] {
    guard k > 0 else { return [] }

    var w = 1.0
    var result: [Element] = []
    result.reserveCapacity(k)
    
    // Fill the reservoir with the first `k` elements.
    var i = startIndex
    while i != endIndex, result.count < k {
      result.append(self[i])
      formIndex(after: &i)
    }
    
    while i != endIndex {
      // Calculate the next value of w.
      w *= nextW(k: k, using: &rng)
      
      // Find index of the next element to swap into the reservoir.
      let offset = nextOffset(w: w, using: &rng)
      i = index(i, offsetBy: offset, limitedBy: endIndex) ?? endIndex
      
      if i != endIndex {
        // Swap selected element with a randomly chosen one in the reservoir.
        let j = Int.random(in: 0..<result.count, using: &rng)
        result[j] = self[i]
        formIndex(after: &i)
      }
    }
    
    // FIXME: necessary?
    result.shuffle(using: &rng)
    return result
  }
  
  /// Randomly selects the specified number of elements from this collection.
  ///
  /// This method is equivalent to calling `randomSample(k:using:)`, passing in
  /// the system's default random generator.
  ///
  /// - Parameter k: The number of elements to randomly select.
  /// - Returns: An array of `k` random elements. The returned elements may be
  ///   in any order. If `k` is greater than this collection's count, then this
  ///   method returns the full collection.
  ///
  /// - Complexity: O(*k*), where *k* is the number of elements to select, if
  ///   the collection conforms to `RandomAccessCollection`. Otherwise, O(*n*),
  ///   where *n* is the length of the collection.
  @inlinable
  public func randomSample(count k: Int) -> [Element] {
    var g = SystemRandomNumberGenerator()
    return randomSample(count: k, using: &g)
  }
}

extension Sequence {
  /// Randomly selects the specified number of elements from this sequence.
  ///
  /// - Parameters:
  ///   - k: The number of elements to randomly select.
  ///   - rng: The random number generator to use for the sampling.
  /// - Returns: An array of `k` random elements. The returned elements may be
  ///   in any order. If `k` is greater than this sequence's count, then this
  ///   method returns the full sequence.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func randomSample<G: RandomNumberGenerator>(
    count k: Int, using rng: inout G
  ) -> [Element] {
    guard k > 0 else { return [] }
    
    var w = 1.0
    var result: [Element] = []
    result.reserveCapacity(k)
    
    // Fill the reservoir with the first `k` elements.
    var iterator = makeIterator()
    while result.count < k, let el = iterator.next() {
      result.append(el)
    }

    while true {
      // Calculate the next value of w.
      w *= nextW(k: k, using: &rng)
      
      // Find the offset of the next element to swap into the reservoir.
      var offset = nextOffset(w: w, using: &rng)
      
      // Skip over `offset` elements to find the selected element.
      while offset > 0, let _ = iterator.next() {
        offset -= 1
      }
      guard let nextElement = iterator.next() else { break }
      
      // Swap selected element with a randomly chosen one in the reservoir.
      let j = Int.random(in: 0..<result.count, using: &rng)
      result[j] = nextElement
    }
    
    // FIXME: necessary?
    result.shuffle(using: &rng)
    return result
  }
  
  /// Randomly selects the specified number of elements from this sequence.
  ///
  /// This method is equivalent to calling `randomSample(k:using:)`, passing in
  /// the system's default random generator.
  ///
  /// - Parameter k: The number of elements to randomly select.
  /// - Returns: An array of `k` random elements. The returned elements may be
  ///   in any order. If `k` is greater than this sequence's count, then this
  ///   method returns the full sequence.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the sequence.
  @inlinable
  public func randomSample(count k: Int) -> [Element] {
    var g = SystemRandomNumberGenerator()
    return randomSample(count: k, using: &g)
  }
}
