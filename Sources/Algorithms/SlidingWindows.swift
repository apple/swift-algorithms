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

//===----------------------------------------------------------------------===//
// slidingWindows(ofCount:)
//===----------------------------------------------------------------------===//

extension Collection {
  /// A collection for all contiguous windows of length size, the
  /// windows overlap.
  ///
  /// - Complexity: O(*1*) if the collection conforms to
  /// `RandomAccessCollection`, otherwise O(*k*) where `k` is `count`.
  /// Access to the next window is O(*1*).
  ///
  /// - Parameter count: The number of elements in each window subsequence.
  ///
  /// - Returns: If the collection is shorter than `size` the resulting
  /// SlidingWindows collection will be empty.
  public func slidingWindows(ofCount count: Int) -> SlidingWindows<Self> {
    SlidingWindows(base: self, size: count)
  }
}

public struct SlidingWindows<Base: Collection> {
  
  public let base: Base
  public let size: Int
  
  private var firstUpperBound: Base.Index?

  init(base: Base, size: Int) {
    precondition(size > 0, "SlidingWindows size must be greater than zero")
    self.base = base
    self.size = size
    self.firstUpperBound = base.index(base.startIndex, offsetBy: size, limitedBy: base.endIndex)
  }
}

extension SlidingWindows: Collection {
  
  public struct Index: Comparable {
    internal var lowerBound: Base.Index
    internal var upperBound: Base.Index
    public static func == (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound == rhs.lowerBound
    }
    public static func < (lhs: Index, rhs: Index) -> Bool {
      lhs.lowerBound < rhs.lowerBound
    }
  }
  
  public var startIndex: Index {
    if let upperBound = firstUpperBound {
      return Index(lowerBound: base.startIndex, upperBound: upperBound)
    } else {
      return endIndex
    }
  }
  
  public var endIndex: Index {
    Index(lowerBound: base.endIndex, upperBound: base.endIndex)
  }
  
  public subscript(index: Index) -> Base.SubSequence {
    precondition(index.lowerBound != index.upperBound, "SlidingWindows index is out of range")
    return base[index.lowerBound..<index.upperBound]
  }
  
  public func index(after index: Index) -> Index {
    precondition(index < endIndex, "Advancing past end index")
    guard index.upperBound < base.endIndex else { return endIndex }
    return Index(
      lowerBound: base.index(after: index.lowerBound),
      upperBound: base.index(after: index.upperBound)
    )
  }
  
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    guard distance != 0 else { return i }
    
    return distance > 0
      ? offsetForward(i, by: distance)
      : offsetBackward(i, by: -distance)
  }
  
  public func index(
    _ i: Index,
    offsetBy distance: Int,
    limitedBy limit: Index
  ) -> Index? {
    guard distance != 0 else { return i }
    guard limit != i else { return nil }
    
    if distance > 0 {
      return limit > i
        ? offsetForward(i, by: distance, limitedBy: limit)
        : offsetForward(i, by: distance)
    } else {
      return limit < i
        ? offsetBackward(i, by: -distance, limitedBy: limit)
        : offsetBackward(i, by: -distance)
    }
  }
  
  private func offsetForward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetForward(i, by: distance, limitedBy: endIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }
  
  private func offsetBackward(_ i: Index, by distance: Int) -> Index {
    guard let index = offsetBackward(i, by: distance, limitedBy: startIndex)
      else { fatalError("Index is out of bounds") }
    return index
  }
  
  private func offsetForward(
    _ i: Index, by distance: Int, limitedBy limit: Index
  ) -> Index? {
    assert(distance > 0)
    assert(limit > i)
    
    // `endIndex` and the index before it both have `base.endIndex` as their
    // upper bound, so we first advance to the base index _before_ the upper
    // bound of the output, in order to avoid advancing past the end of `base`
    // when advancing to `endIndex`.
    //
    // Advancing by 4:
    //
    //  input: [x|x x x x x|x x x x]        [x x|x x x x x|x x x]
    //                     |> > >|>|   or                 |> > >|
    // output: [x x x x x|x x x x x]        [x x x x x x x x x x]  (`endIndex`)
    
    if distance >= size {
      // Avoid traversing `self[i.lowerBound..<i.upperBound]` when the lower
      // bound of the output is greater than or equal to the upper bound of the
      // input.
      
      //  input: [x|x x x x|x x x x x x x]
      //                   |> >|> > >|>|
      // output: [x x x x x x x|x x x x|x]
      
      guard limit.lowerBound >= i.upperBound,
            let lowerBound = base.index(
              i.upperBound,
              offsetBy: distance - size,
              limitedBy: limit.lowerBound),
            let indexBeforeUpperBound = base.index(
              lowerBound,
              offsetBy: size - 1,
              limitedBy: limit.upperBound)
      else { return nil }
      
      // If `indexBeforeUpperBound` equals `base.endIndex`, we're advancing to
      // `endIndex`.
      guard indexBeforeUpperBound != base.endIndex else { return endIndex }
      
      return Index(
        lowerBound: lowerBound,
        upperBound: base.index(after: indexBeforeUpperBound))
    } else {
      //  input: [x|x x x x x x|x x x x x]
      //           |> > > >|   |> > >|>|
      // output: [x x x x x|x x x x x x|x]
      
      guard let indexBeforeUpperBound = base.index(
              i.upperBound,
              offsetBy: distance - 1,
              limitedBy: limit.upperBound)
      else { return nil }
      
      // If `indexBeforeUpperBound` equals the limit, the upper bound itself
      // exceeds it.
      guard indexBeforeUpperBound != limit.upperBound || limit == endIndex
        else { return nil }
      
      // If `indexBeforeUpperBound` equals `base.endIndex`, we're advancing to
      // `endIndex`.
      guard indexBeforeUpperBound != base.endIndex else { return endIndex }
      
      return Index(
        lowerBound: base.index(i.lowerBound, offsetBy: distance),
        upperBound: base.index(after: indexBeforeUpperBound))
    }
  }
  
  private func offsetBackward(
      _ i: Index, by distance: Int, limitedBy limit: Index
    ) -> Index? {
    assert(distance > 0)
    assert(limit < i)
    
    if i == endIndex {
      // Advance `base.endIndex` by `distance - 1`, because the index before
      // `endIndex` also has `base.endIndex` as its upper bound.
      //
      // Advancing by 4:
      //
      //  input: [x x x x x x x x x x]  (`endIndex`)
      //             |< < < < <|< < <|
      // output: [x x|x x x x x|x x x]
      
      guard let upperBound = base.index(
              base.endIndex,
              offsetBy: -(distance - 1),
              limitedBy: limit.upperBound)
      else { return nil }
      
      return Index(
        lowerBound: base.index(upperBound, offsetBy: -size),
        upperBound: upperBound)
    } else if distance >= size {
      // Avoid traversing `self[i.lowerBound..<i.upperBound]` when the upper
      // bound of the output is less than or equal to the lower bound of the
      // input.
      //
      //  input: [x x x x x x x|x x x x|x]
      //           |< < < <|< <|
      // output: [x|x x x x|x x x x x x x]
      
      guard limit.upperBound <= i.lowerBound,
            let upperBound = base.index(
              i.lowerBound,
              offsetBy: -(distance - size),
              limitedBy: limit.upperBound)
      else { return nil }
      
      return Index(
        lowerBound: base.index(upperBound, offsetBy: -size),
        upperBound: upperBound)
    } else {
      //  input: [x x x x x|x x x x x x|x]
      //           |< < < <|   |< < < <|
      // output: [x|x x x x x x|x x x x x]
      
      guard let lowerBound = base.index(
              i.lowerBound,
              offsetBy: -distance,
              limitedBy: limit.lowerBound)
      else { return nil }
      
      return Index(
        lowerBound: lowerBound,
        upperBound: base.index(i.lowerBound, offsetBy: -distance))
    }
  }
  
  public func distance(from start: Index, to end: Index) -> Int {
    guard start <= end else { return -distance(from: end, to: start) }
    guard start != end else { return 0 }
    guard end < endIndex else {
      // We add 1 here because the index before `endIndex` also has
      // `base.endIndex` as its upper bound.
      return base[start.upperBound...].count + 1
    }

    if start.upperBound <= end.lowerBound {
      // The distance between `start.lowerBound` and `start.upperBound` is
      // already known.
      //
      // start: [x|x x x x|x x x x x x x]
      //          |- - - -|> >|
      //   end: [x x x x x x x|x x x x|x]
      
      return size + base[start.upperBound..<end.lowerBound].count
    } else {
      // start: [x|x x x x x x|x x x x x]
      //          |> > > >|
      //   end: [x x x x x|x x x x x x|x]
      
      return base[start.lowerBound..<end.lowerBound].count
    }
  }
}

extension SlidingWindows: BidirectionalCollection where Base: BidirectionalCollection {
  public func index(before index: Index) -> Index {
    precondition(index > startIndex, "Incrementing past start index")
    if index == endIndex {
      return Index(
        lowerBound: base.index(index.lowerBound, offsetBy: -size),
        upperBound: index.upperBound
      )
    } else {
      return Index(
        lowerBound: base.index(before: index.lowerBound),
        upperBound: base.index(before: index.upperBound)
      )
    }
  }
}

extension SlidingWindows: RandomAccessCollection where Base: RandomAccessCollection {}
extension SlidingWindows: Equatable where Base: Equatable {}
extension SlidingWindows: Hashable where Base: Hashable, Base.Index: Hashable {}
extension SlidingWindows.Index: Hashable where Base.Index: Hashable {}
