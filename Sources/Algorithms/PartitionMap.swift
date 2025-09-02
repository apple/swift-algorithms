//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Algorithms open source project
//
// Copyright (c) 2020-2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// PartitionMapResult2
//===----------------------------------------------------------------------===//

public struct PartitionMapResult2<A, B> {
  @usableFromInline
  internal let oneOf: _PartitionMapResult2<A, B>
  
  @inlinable
  internal init(oneOf: _PartitionMapResult2<A, B>) {
    self.oneOf = oneOf
  }
  
  @inlinable
  public static func first(_ value: A) -> Self {
    Self(oneOf: .first(value))
  }
  
  @inlinable
  public static func second(_ value: B) -> Self {
    Self(oneOf: .second(value))
  }
}

@usableFromInline
internal enum _PartitionMapResult2<A, B> {
  case first(A)
  case second(B)
}

//===----------------------------------------------------------------------===//
// PartitionMapResult3
//===----------------------------------------------------------------------===//

public struct PartitionMapResult3<A, B, C> {
  @usableFromInline
  internal let oneOf: _PartitionMapResult3<A, B, C>
  
  @inlinable
  internal init(oneOf: _PartitionMapResult3<A, B, C>) {
    self.oneOf = oneOf
  }
  
  @inlinable
  public static func first(_ value: A) -> Self {
    Self(oneOf: .first(value))
  }
  
  @inlinable
  public static func second(_ value: B) -> Self {
    Self(oneOf: .second(value))
  }
  
  @inlinable
  public static func third(_ value: C) -> Self {
    Self(oneOf: .third(value))
  }
}

@usableFromInline
internal enum _PartitionMapResult3<A, B, C> {
  case first(A)
  case second(B)
  case third(C)
}

//===----------------------------------------------------------------------===//
// partitionMap()
//===----------------------------------------------------------------------===//

extension Sequence {
  /// Allows to separate elements into distinct groups while applying a transformation to each element
  ///
  /// This method do the same as `partitioned(by:)` but with an added map step baked in for
  /// ergonomic reasons.
  ///
  /// The `partitionMap` applies the given closure to each element of the collection and divides the
  /// results into two groups based on the transformation's output.
  /// The closure returns a `PartitionMapResult`, which indicates whether the result should be
  /// included in the first group or in the second.
  ///
  /// Example 1:
  /// ```
  /// func process(results: [Result<Response, any Error>]) {
  ///   let (successes, failures) = results
  ///     .partitionMap { result -> PartitionMapResult2<Response, any Error> in
  ///       switch result {
  ///       case .success(let value): .first(value)
  ///       case .failure(let error): .second(error)
  ///       }
  ///     }
  ///  }
  /// ```
  /// Example 2:
  /// `partitionMap(_:)` is used to separate an array  of `any Error` elements into two arrays while
  /// also transforming the type from `any Error` to `URLSessionError` for the first group.
  /// ```
  /// func handle(errors: [any Error]) {
  ///   let (urlSessionErrors, unknownErrors) = errors
  ///     .partitionMap { error -> PartitionMapResult2<URLSessionError, any Error> in
  ///       switch error {
  ///       case let urlError as URLSessionError: .first(urlError)
  ///       default: .second(error)
  ///       }
  ///     }
  ///   // `urlSessionErrors` Type is `Array<URLSessionError>`
  ///   // `unknownErrors` Type is `Array<any Error>`
  ///  }
  /// ```
  ///
  /// - Parameters:
  ///   - transform: A mapping closure. `transform` accepts an element of this sequence as its
  ///   parameter and returns a `PartitionMapResult` with a transformed value, representing
  ///   membership to either the first or second group with elements of the original or of a different type.
  ///
  /// - Returns: Two arrays, with elements from the first or second group appropriately.
  ///
  /// - Throws: Rethrows any errors produced by the `transform` closure.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func partitionMap<A, B, Error>(
    _ transform: (Element) throws(Error) -> PartitionMapResult2<A, B>
  ) throws(Error) -> ([A], [B]) {
    var groupA: [A] = []
    var groupB: [B] = []
    
    for element in self {
      switch try transform(element).oneOf {
      case .first(let a): groupA.append(a)
      case .second(let b): groupB.append(b)
      }
    }
    
    return (groupA, groupB)
  }
  
  /// Allows to separate elements into distinct groups while applying a transformation to each element
  ///
  /// This method do the same as `partitioned(by:)` but with an added map step baked in for
  /// ergonomic reasons.
  ///
  /// The `partitionMap` applies the given closure to each element of the collection and divides the
  /// results into distinct groups based on the transformation's output.
  /// The closure returns a `PartitionMapResult`, which indicates whether the result should be
  /// included in the first , second or third group.
  /// - Example 1:
  /// ```
  /// func process(results: [Result<Product, any Error>]) {
  ///   let (successes, failures) = results
  ///     .partitionMap { result -> PartitionMapResult2<Response, any Error> in
  ///       switch result {
  ///       case .success(let value): .first(value)
  ///       case .failure(let error): .second(error)
  ///     }
  ///   }
  /// }
  /// ```
  /// - Example 2:
  /// `partitionMap(_:)` is used to separate an array  of `any Error` elements into three arrays
  /// while also transforming the type from
  /// `any Error` to `URLSessionError` for the first and second groups.
  /// ```
  /// func handle(errors: [any Error]) {
  ///   let (urlSessionErrors, httpErrors, unknownErrors) = errors
  ///     .partitionMap { error -> PartitionMapResult3<URLSessionError, any Error> in
  ///       switch error {
  ///       case let urlError as URLSessionError:
  ///         .first(urlError)
  ///       case let httpError as HTTPError:
  ///         .second(urlError)
  ///       default:
  ///         .third(error)
  ///       }
  ///     }
  ///   // `urlSessionErrors` Type `is Array<URLSessionError>`
  ///   // `httpErrors` Type is `Array<URLSessionError>`
  ///   // `unknownErrors` Type is `Array<any Error>`
  ///  }
  /// ```
  ///
  /// - Parameters:
  ///   - transform: A mapping closure. `transform` accepts an element of this sequence as its
  ///   parameter and returns a `PartitionMapResult` with a transformed value, representing
  ///   membership to either first, second or third group with elements of the original or of a different type.
  ///
  /// - Returns: Three arrays, with elements from the first, second or third group appropriately.
  ///
  /// - Throws: Rethrows any errors produced by the `transform` closure.
  ///
  /// - Complexity: O(*n*), where *n* is the length of the collection.
  @inlinable
  public func partitionMap<A, B, C, Error>(
    _ transform: (Element) throws(Error) -> PartitionMapResult3<A, B, C>
  ) throws(Error) -> ([A], [B], [C]) {
    var groupA: [A] = []
    var groupB: [B] = []
    var groupC: [C] = []
    
    for element in self {
      switch try transform(element).oneOf {
      case .first(let a): groupA.append(a)
      case .second(let b): groupB.append(b)
      case .third(let c): groupC.append(c)
      }
    }
    
    return (groupA, groupB, groupC)
  }
}
