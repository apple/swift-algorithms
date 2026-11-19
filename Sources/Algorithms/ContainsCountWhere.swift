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
// contains(countIn:where:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns whether or not the number of elements of the sequence that satisfy
  /// the given predicate fall within a given range.
  ///
  /// The following example determines if there are multiple (at least two)
  /// types of animals with “lion” in its name:
  ///
  ///     let animals = [
  ///         "mountain lion",
  ///         "lion",
  ///         "snow leopard",
  ///         "leopard",
  ///         "tiger",
  ///         "panther",
  ///         "jaguar"
  ///     ]
  ///     print(animals.contains(countIn: 2..., where: { $0.contains("lion") }))
  ///     // prints "true"
  ///
  /// - Parameters:
  ///   - rangeExpression: The range of acceptable counts
  ///   - predicate: A closure that takes an element as its argument and returns
  ///   a Boolean value indicating whether the element should be included in the
  ///   count.
  /// - Returns: Whether or not the number of elements in the sequence that
  /// satisfy the given predicate is within a given range
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains<R: RangeExpression>(
    countIn rangeExpression: R,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool where R.Bound: FixedWidthInteger {
    let range = rangeExpression.relative(to: R.Bound.zero..<R.Bound.max)
    
    // If the upper bound is less than the max value, iteration can stop once it
    // reaches the range’s upper bound and return `false`, since the bounds have
    // been exceeded.
    // Otherwise, treat the range as unbounded. As soon as the count reaches the
    // range’s lower bound, iteration can stop and return `true`.
    let threshold: R.Bound
    let thresholdReturn: Bool
    if range.upperBound < R.Bound.max {
      threshold = range.upperBound
      thresholdReturn = false
    } else {
      threshold = range.lowerBound
      thresholdReturn = true
    }
    
    var count: R.Bound = .zero
    for element in self {
      if try predicate(element) {
        count += 1
        
        // Return early if we’ve reached the threshold.
        if count >= threshold {
          return thresholdReturn
        }
      }
    }
    
    return range.contains(count)
  }
}

//===----------------------------------------------------------------------===//
// contains(exactly:where:)
// contains(atLeast:where:)
// contains(moreThan:where:)
// contains(lessThan:where:)
// contains(lessThanOrEqualTo:where:)
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Returns whether or not an exact number of elements of the sequence satisfy
  /// the given predicate.
  ///
  /// The following example determines if there are exactly two bears:
  ///
  ///     let animals = [
  ///         "bear",
  ///         "fox",
  ///         "bear",
  ///         "squirrel",
  ///         "bear",
  ///         "moose",
  ///         "squirrel",
  ///         "elk"
  ///     ]
  ///     print(animals.contains(exactly: 2, where: { $0 == "bear" }))
  ///     // prints "false"
  ///
  /// Using `contains(exactly:where:)` is faster than using `filter(where:)` and
  /// comparing its `count` using `==` because this function can return early,
  /// without needing to iterating through all elements to get an exact count.
  /// If, and as soon as, the count exceeds 2, it returns `false`.
  ///
  /// - Parameter exactCount: The exact number to expect
  /// - Parameter predicate: A closure that takes an element as its argument and
  /// returns a Boolean value indicating whether the element should be included
  /// in the count.
  /// - Returns: Whether or not exactly `exactCount` number of elements in the
  /// sequence passed `predicate`
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains(
    exactly exactCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool {
    return try self.contains(countIn: exactCount...exactCount, where: predicate)
  }
  
  /// Returns whether or not at least a given number of elements of the sequence
  /// satisfy the given predicate.
  ///
  /// The following example determines if there are at least two numbers that
  /// are a multiple of 3:
  ///
  ///     let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     print(numbers.contains(atLeast: 2, where: { $0.isMultiple(of: 3) }))
  ///     // prints "true"
  ///
  /// Using `contains(atLeast:where:)` is faster than using `filter(where:)` and
  /// comparing its `count` using `>=` because this function can return early,
  /// without needing to iterating through all elements to get an exact count.
  /// If, and as soon as, the count reaches 2, it returns `true`.
  ///
  /// - Parameter minimumCount: The minimum number to count before returning
  /// - Parameter predicate: A closure that takes an element as its argument and
  /// returns a Boolean value indicating whether the element should be included
  /// in the count.
  /// - Returns: Whether or not at least `minimumCount` number of elements in
  /// the sequence passed `predicate`
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains(
    atLeast minimumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool {
    return try self.contains(countIn: minimumCount..., where: predicate)
  }
  
  /// Returns whether or not more than a given number of elements of the
  /// sequence satisfy the given predicate.
  ///
  /// The following example determines if there are more than two numbers that
  /// are a multiple of 3:
  ///
  ///     let numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  ///     print(numbers.contains(moreThan: 2, where: { $0.isMultiple(of: 3) }))
  ///     // prints "true"
  ///
  /// Using `contains(moreThan:where:)` is faster than using `filter(where:)`
  /// and comparing its `count` using `>` because this function can return
  /// early, without needing to iterating through all elements to get an exact
  /// count. If, and as soon as, the count reaches 2, it returns `true`.
  ///
  /// - Parameter minimumCount: The minimum number to count before returning
  /// - Parameter predicate: A closure that takes an element as its argument and
  /// returns a Boolean value indicating whether the element should be included
  /// in the count.
  /// - Returns: Whether or not more than `minimumCount` number of elements in
  /// the sequence passed `predicate`
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains(
    moreThan minimumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool {
    return try self.contains(countIn: (minimumCount + 1)..., where: predicate)
  }
  
  /// Returns whether or not fewer than a given number of elements of the
  /// sequence satisfy the given predicate.
  ///
  /// The following example determines if there are fewer than five numbers in
  /// the sequence that are multiples of 10:
  ///
  ///     let numbers = [1, 2, 5, 10, 20, 50, 100, 1, 1, 5, 2]
  ///     print(numbers.contains(lessThan: 5, where: { $0.isMultiple(of: 10) }))
  ///     // prints "true"
  ///
  /// Using `contains(moreThan:where:)` is faster than using `filter(where:)`
  /// and comparing its `count` using `>` because this function can return
  /// early, without needing to iterating through all elements to get an exact
  /// count. If, and as soon as, the count reaches 2, it returns `true`.
  ///
  /// - Parameter maximumCount: The maximum number to count before returning
  /// - Parameter predicate: A closure that takes an element as its argument and
  /// returns a Boolean value indicating whether the element should be included
  /// in the count.
  /// - Returns: Whether or not less than `maximumCount` number of elements in
  /// the sequence passed `predicate`
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains(
    lessThan maximumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool {
    return try self.contains(countIn: ..<maximumCount, where: predicate)
  }
  
  /// Returns whether or not the number of elements of the sequence that satisfy
  /// the given predicate is less than or equal to a given number.
  ///
  /// The following example determines if there are less than or equal to five
  /// numbers in the sequence that are multiples of 10:
  ///
  ///     let numbers = [1, 2, 5, 10, 20, 50, 100, 1000, 1, 1, 5, 2]
  ///     print(numbers.contains(lessThanOrEqualTo: 5, where: {
  ///         $0.isMultiple(of: 10)
  ///     }))
  ///     // prints "true"
  ///
  /// Using `contains(lessThanOrEqualTo:where:)` is faster than using
  /// `filter(where:)` and comparing its `count` with `>` because this function
  /// can return early, without needing to iterating through all elements to get
  /// an exact count. If, and as soon as, the count exceeds `maximumCount`,
  /// it returns `false`.
  ///
  /// - Parameter maximumCount: The maximum number to count before returning
  /// - Parameter predicate: A closure that takes an element as its argument and
  /// returns a Boolean value indicating whether the element should be included
  /// in the count.
  /// - Returns: Whether or not the number of elements that pass `predicate` is
  /// less than or equal to `maximumCount`
  /// the sequence passed `predicate`
  /// - Complexity: Worst case O(*n*), where *n* is the number of elements.
  @inlinable
  public func contains(
    lessThanOrEqualTo maximumCount: Int,
    where predicate: (Element) throws -> Bool
  ) rethrows -> Bool {
    return try self.contains(countIn: ...maximumCount, where: predicate)
  }
}
